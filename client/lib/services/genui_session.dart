// Copyright 2026 Oaktreeapps
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../core/app_logging.dart';
import 'transport.dart';

/// The A2UI version the app speaks: every message it sends carries it.
final String a2uiVersion = A2uiProtocolVersion.v1_0.jsonValue;

/// Runs a generative UI flow: sends requests to the backend and turns its
/// A2UI v1.0 responses into surfaces.
///
/// Flow: screen → [GenUiSession] → [Transport] (the backend's agent for the
/// flow). Responses come back through the transport into a2ui_core's
/// [MessageProcessor], which keeps each surface's components and data model;
/// a button tap on a surface is sent back to the backend as the next
/// request.
class GenUiSession extends ChangeNotifier {
  /// Creates a session that talks to the backend through [transport] and
  /// renders its screens with the components in [catalog].
  ///
  /// The session starts listening right away; call [sendMessage] to start
  /// the flow.
  GenUiSession({
    required Transport transport,
    required CatalogImplementation catalog,
  }) : _transport = transport,
       processor = MessageProcessor<ComponentImplementation>(
         catalogs: [catalog],
         defaultVersion: A2uiProtocolVersion.v1_0,
         // A message the app can't use is reported (see [_onRendererError])
         // instead of thrown.
         reportErrorsOnly: true,
       ) {
    _logger.info(
      'created with ${catalog.components.length} catalog components '
      '→ ${transport.runtimeType} + MessageProcessor',
    );
    _init();
  }

  /// Logger for every session's messages.
  static final Logger _logger = Logger('GenUiSession');

  /// Sends requests to the backend and receives its A2UI messages.
  final Transport _transport;

  /// a2ui_core's processor: it builds surfaces from the A2UI messages and
  /// reports their button taps and errors.
  ///
  /// Public for the widgets that draw a surface, and for tests.
  final MessageProcessor<ComponentImplementation> processor;

  /// Feeds the transport's A2UI messages into [processor].
  late final StreamSubscription<JsonMap> _messageSub;

  /// Logs any plain text the agent sends next to its A2UI messages.
  late final StreamSubscription<String> _textSub;

  /// The listeners on [processor]'s surfaces, taps and errors.
  final List<Subscription> _processorSubs = [];

  /// The source of [actions]. Broadcast, so many screens may listen.
  final StreamController<UserAction> _actions =
      StreamController<UserAction>.broadcast();

  /// Every UI action the user sends from a surface (a button tap), with the
  /// values in its context, e.g. to collect a flow's answers.
  Stream<UserAction> get actions => _actions.stream;

  /// Actions the app handles itself, e.g. leaving a flow: they go to
  /// [actions] but are not sent to the backend.
  static const Set<String> localActions = {
    goToDashboardAction,
    chooseCareCityAction,
    finishAction,
  };

  /// The error reports already sent to the backend, as JSON text.
  ///
  /// A surface the app can't draw may report the same error again each time
  /// it is rebuilt, and the backend's reply causes another rebuild. Sending
  /// each report only once stops that loop.
  final Set<String> _sentErrors = {};

  /// Error reports that came up while a request was in flight; they are
  /// sent, one at a time, once it has ended.
  final List<String> _waitingErrors = [];

  /// The ids of all surfaces the agent has created so far, oldest first.
  final List<String> _surfaceIds = [];

  /// The most recently created surface, or `null` before the first one.
  String? get currentSurfaceId => _surfaceIds.lastOrNull;

  /// The surface with [surfaceId], or `null` if the agent removed it (or
  /// never created it).
  SurfaceModel<ComponentImplementation>? surfaceFor(String surfaceId) =>
      processor.model.getSurface(surfaceId);

  /// Backing field for [isProcessing].
  bool _isProcessing = false;

  /// Whether a request is in flight, e.g. to show a progress bar. Only one
  /// request runs at a time; others are ignored while this is `true`.
  bool get isProcessing => _isProcessing;

  /// Backing field for [error].
  Object? _error;

  /// The error from the last request, cleared when a new request starts.
  Object? get error => _error;

  /// Whether [dispose] was called. A request can still be running then, and
  /// must not touch the session when it ends.
  bool _disposed = false;

  /// What goes with every request: the A2UI version and catalog the app
  /// renders, so the agent knows what it may send.
  late final JsonMap _requestMetadata = {
    'a2uiRendererCapabilities': processor
        .getRendererCapabilities(
          const CapabilitiesOptions(versions: [A2uiProtocolVersion.v1_0]),
        )
        .toJson(),
  };

  /// Connects the transport and the processor: incoming messages go to the
  /// processor, and taps on a surface go to [actions] and, unless they are
  /// in [localActions], back to the backend.
  void _init() {
    _messageSub = _transport.incomingMessages.listen(_onMessage);
    _textSub = _transport.incomingText.listen(
      (text) => _logger.fine('Agent text: "${preview(text)}"'),
    );
    _processorSubs.addAll([
      processor.model.onSurfaceCreated.subscribe(_onSurfaceCreated),
      processor.model.onSurfaceDeleted.subscribe(_onSurfaceDeleted),
      processor.model.onAction.subscribe(_onAction),
      processor.model.onError.subscribe(_onRendererError),
    ]);
  }

  /// Applies one A2UI [message] from the agent to its surface.
  void _onMessage(JsonMap message) {
    _logger.info(
      'Transport → MessageProcessor.processMessages: '
      '${message.keys.where((key) => key != 'version').join(', ')}',
    );
    _logger.finest(() => 'A2UI message: ${preview(message)}');
    try {
      processor.processMessages(message);
    } on Object catch (error, stackTrace) {
      // The processor reports A2UI errors itself; anything else is a bug.
      _logger.severe('Could not apply an A2UI message', error, stackTrace);
    }
  }

  /// Adds a surface the agent created and tells listeners it is the current
  /// one now.
  void _onSurfaceCreated(SurfaceModel<ComponentImplementation> surface) {
    if (_surfaceIds.contains(surface.id)) return;
    _logger.info('New surface #${_surfaceIds.length}: ${surface.id}');
    _processorSubs.add(
      surface.onWarning.subscribe(
        (warning) => _logger.fine('Surface ${surface.id}: ${warning.message}'),
      ),
    );
    _surfaceIds.add(surface.id);
    notifyListeners();
  }

  /// Forgets a surface the agent removed.
  void _onSurfaceDeleted(String surfaceId) {
    _logger.warning('Surface $surfaceId removed by the agent');
    _surfaceIds.remove(surfaceId);
    if (!_disposed) notifyListeners();
  }

  /// Handles a button tap on a surface: it goes to [actions] and, unless it
  /// is one of the [localActions], to the backend as the next request.
  void _onAction(A2uiRendererAction rendererAction) {
    final UserAction action = userActionFrom(rendererAction);
    if (localActions.contains(action.name)) {
      _logger.info('Surface action → local ${action.name}');
      _actions.add(action);
      return;
    }
    // Checked before the action is passed on, so a tap that is dropped
    // isn't saved either.
    if (_isProcessing) {
      _logger.warning('${action.name} ignored: a request is in progress');
      return;
    }
    _actions.add(action);
    _logger.info(
      'Surface action (user tapped ${action.name}) → Transport.sendRequest',
    );
    // The values the user entered: health data, so only at FINEST.
    _logger.finest(() => 'Action context: ${action.context}');
    final JsonMap message = ActionMessage(
      version: a2uiVersion,
      action: rendererAction,
    ).toJson();
    unawaited(_runRequest(() => _send(TransportRequest.data(message))));
  }

  /// Reports a surface the app can't draw (e.g. a component that doesn't
  /// follow its schema) to the backend, each report only once.
  void _onRendererError(A2uiRendererError error) {
    _logger.warning('A2UI error ${error.code}: ${error.message}');
    final String report = jsonEncode(
      ErrorMessage(version: a2uiVersion, error: error).toJson(),
    );
    if (_sentErrors.contains(report) || _waitingErrors.contains(report)) {
      _logger.fine('Error report already sent: ${preview(report)}');
      return;
    }
    if (_isProcessing) {
      // Usually the request in flight caused it; report once it has ended.
      _waitingErrors.add(report);
      return;
    }
    _sendErrorReport(report);
  }

  /// Sends one error [report] to the backend, which logs it.
  void _sendErrorReport(String report) {
    _sentErrors.add(report);
    _logger.info('Error report → Transport.sendRequest');
    final Map<String, Object?> message = (jsonDecode(report) as Map)
        .cast<String, Object?>();
    unawaited(_runRequest(() => _send(TransportRequest.data(message))));
  }

  /// Sends [request] with the app's A2UI capabilities.
  Future<void> _send(TransportRequest request) => _transport.sendRequest(
    request.data == null
        ? TransportRequest.text(request.text!, metadata: _requestMetadata)
        : TransportRequest.data(request.data!, metadata: _requestMetadata),
  );

  /// Sends a text request to the agent, e.g. to start a flow.
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    await _runRequest(() {
      _logger.info('GenUiSession → Transport.sendRequest (text message)');
      _logger.finest(() => 'Text: "${preview(text)}"');
      return _send(TransportRequest.text(text));
    });
  }

  /// Sends a UI action the app makes itself rather than a tap on a surface,
  /// e.g. [findNearbyCareAction] with the city typed in a dialog. The
  /// backend gets it like a button tap, and it goes to [actions] too.
  ///
  /// Ignored, like a tap, while another request is in progress.
  Future<void> sendAction(String name, Map<String, Object?> context) async {
    if (_isProcessing) {
      _logger.warning('$name ignored: a request is in progress');
      return;
    }
    _actions.add((name: name, context: context));
    _logger.info('GenUiSession → Transport.sendRequest (app action $name)');
    await sendMessage(actionMessage(name, context));
  }

  /// Runs one request in [body], keeping [isProcessing] and [error] up to
  /// date and telling listeners when the request starts and ends.
  ///
  /// Errors are caught and stored in [error] instead of being thrown.
  Future<void> _runRequest(Future<void> Function() body) async {
    // Only one request runs at a time.
    if (_isProcessing) {
      _logger.warning('Request ignored: another request is in progress');
      return;
    }

    _error = null;
    _isProcessing = true;
    notifyListeners();
    final stopwatch = Stopwatch()..start();
    _logger.info('Request started (isProcessing=true)');
    try {
      await body();
      _logger.info('Request completed in ${stopwatch.elapsedMilliseconds}ms');
    } on Exception catch (exception, stackTrace) {
      _logger.severe('Error sending request', exception, stackTrace);
      _error = exception;
    } finally {
      // The screen may have closed while the request was running.
      if (!_disposed) {
        _isProcessing = false;
        _logger.fine('isProcessing=false → notifyListeners');
        notifyListeners();
        // An error the request caused is reported now that it has ended.
        if (_waitingErrors.isNotEmpty) {
          _sendErrorReport(_waitingErrors.removeAt(0));
        }
      }
    }
  }

  /// Stops all listeners and closes the processor, the [actions] stream and
  /// the transport.
  @override
  void dispose() {
    _logger.info('dispose → cancel subscriptions');
    _disposed = true;
    _messageSub.cancel();
    _textSub.cancel();
    for (final Subscription subscription in _processorSubs) {
      subscription.unsubscribe();
    }
    processor.dispose();
    _actions.close();
    _transport.dispose();
    super.dispose();
  }
}

/// The action of the summaries' "Go to dashboard" button.
///
/// It is one of the [GenUiSession.localActions]: the screen closes the flow
/// and the backend never sees it.
const String goToDashboardAction = 'goToDashboard';

/// The action of the report's "Finish" button.
///
/// It is one of the [GenUiSession.localActions]: the screen clears today's
/// log and goes back to the dashboard, to start again.
const String finishAction = 'finish';

/// The action of the daily summary's "Find care nearby" and "Search another
/// city" buttons.
///
/// It is one of the [GenUiSession.localActions]: the screen asks for a city
/// in a dialog, then sends [findNearbyCareAction] with it.
const String chooseCareCityAction = 'chooseCareCity';

/// The action that asks the backend for care near a city, sent by the app
/// after [chooseCareCityAction] with `{"city": <the city typed>}`.
const String findNearbyCareAction = 'findNearbyCare';

/// The text of an A2UI renderer message holding the UI action [name] with
/// [context], as a button tap sends it. The backend treats it as a tap, not
/// as text typed by the user.
String actionMessage(String name, Map<String, Object?> context) => jsonEncode({
  'version': a2uiVersion,
  'action': {'name': name, 'context': context},
});

/// A UI action from a surface: its name and the values in its context.
typedef UserAction = ({String name, Map<String, Object?> context});

/// The name and context values of [action], a tap that a surface reports.
UserAction userActionFrom(A2uiRendererAction action) =>
    (name: action.name, context: Map<String, Object?>.of(action.context));
