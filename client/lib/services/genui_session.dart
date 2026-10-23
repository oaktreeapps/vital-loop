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

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:logging/logging.dart';

import '../core/app_logging.dart';

/// Runs a generative UI flow: sends requests to the backend and turns its
/// A2UI responses into surfaces.
///
/// Flow: screen → [GenUiSession] → [Transport] (the backend's agent for the
/// flow). Responses come back through the transport into the
/// [SurfaceController]; a button tap on a surface is submitted back to the
/// backend as the next request.
class GenUiSession extends ChangeNotifier {
  /// Creates a session that talks to the backend through [transport] and
  /// renders its screens with the components in [catalog].
  ///
  /// The session starts listening right away; call [sendMessage] to start
  /// the flow.
  GenUiSession({required Transport transport, required Catalog catalog})
    : _transport = transport,
      _surfaceController = SurfaceController(catalogs: [catalog]) {
    _logger.info(
      'created with ${catalog.items.length} catalog items '
      '→ ${transport.runtimeType} + SurfaceController',
    );
    _init();
  }

  /// Logger for every session's messages.
  static final Logger _logger = Logger('GenUiSession');

  /// Sends requests to the backend and receives its A2UI messages.
  final Transport _transport;

  /// genui's controller that builds surfaces from A2UI messages and reports
  /// button taps through `onSubmit`.
  final SurfaceController _surfaceController;

  /// Feeds the transport's A2UI messages into [_surfaceController].
  late final StreamSubscription<core.A2uiMessage> _messageSub;

  /// Logs any plain text the agent sends next to its A2UI messages.
  late final StreamSubscription<String> _textSub;

  /// Listens for button taps on a surface and sends them to the backend.
  late final StreamSubscription<ChatMessage> _submitSub;

  /// Listens for surfaces being added or removed, see [_onSurfaceUpdate].
  late final StreamSubscription<SurfaceUpdate> _surfaceSub;

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

  /// The host that renders this session's surfaces.
  SurfaceHost get surfaceHost => _surfaceController;

  /// The error reports already sent to the backend, as JSON text.
  ///
  /// genui reports a surface it can't draw each time it rebuilds it, and the
  /// backend's reply causes another rebuild. Sending each report only once
  /// stops that loop.
  final Set<String> _sentErrors = {};

  /// The ids of all surfaces the agent has created so far, oldest first.
  final List<String> _surfaceIds = [];

  /// The most recently created surface, or `null` before the first one.
  String? get currentSurfaceId => _surfaceIds.lastOrNull;

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

  /// Connects the transport and the surface controller: incoming messages go
  /// to the controller, and taps on a surface go to [actions] and, unless
  /// they are in [localActions], back to the backend.
  void _init() {
    _messageSub = _transport.incomingMessages.listen((message) {
      _logger.info(
        'Transport → SurfaceController.handleMessage: ${message.runtimeType}',
      );
      _logger.finest(() => 'A2UI message: ${preview(message)}');
      _surfaceController.handleMessage(message);
    });
    _textSub = _transport.incomingText.listen(
      (text) => _logger.fine('Agent text: "${preview(text)}"'),
    );
    _submitSub = _surfaceController.onSubmit.listen((message) {
      final UserAction? action = userActionFrom(message);
      if (action != null && localActions.contains(action.name)) {
        _logger.info('SurfaceController.onSubmit → local ${action.name}');
        _actions.add(action);
        return;
      }
      // Checked before the action is passed on, so a tap that is dropped
      // isn't saved either.
      if (_isProcessing) {
        _logger.warning('${action?.name} ignored: a request is in progress');
        return;
      }
      if (action == null) {
        final String? report = errorReportFrom(message);
        if (report != null && !_sentErrors.add(report)) {
          _logger.fine('Error report already sent: ${preview(report)}');
          return;
        }
      }
      if (action != null) _actions.add(action);
      _logger.info(
        'SurfaceController.onSubmit (user tapped ${action?.name}) '
        '→ Transport.sendRequest',
      );
      // The values the user entered: health data, so only at FINEST.
      _logger.finest(() => 'Action context: ${action?.context}');
      unawaited(_runRequest(() => _transport.sendRequest(message)));
    });
    _surfaceSub = _surfaceController.surfaceUpdates.listen(_onSurfaceUpdate);
  }

  /// Keeps [_surfaceIds] in step with the surfaces the agent creates and
  /// removes, and tells listeners when the current surface changes.
  void _onSurfaceUpdate(SurfaceUpdate update) {
    _logger.info('SurfaceController → surfaceUpdate: ${update.runtimeType}');
    switch (update) {
      case SurfaceAdded(:final surfaceId):
        if (!_surfaceIds.contains(surfaceId)) {
          _logger.info('New surface #${_surfaceIds.length}: $surfaceId');
          _surfaceIds.add(surfaceId);
          notifyListeners();
        }
      case SurfaceRemoved(:final surfaceId):
        _logger.warning('Surface $surfaceId removed by the agent');
        _surfaceIds.remove(surfaceId);
        notifyListeners();
      case ComponentsUpdated():
        // The surface widget redraws itself; nothing to do here.
        break;
    }
  }

  /// Sends a text request to the agent, e.g. to start a flow.
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    await _runRequest(() {
      _logger.info('GenUiSession → Transport.sendRequest (text message)');
      _logger.finest(() => 'Text: "${preview(text)}"');
      return _transport.sendRequest(ChatMessage.user(text));
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
      }
    }
  }

  /// Stops all listeners and closes the controller, the [actions] stream and
  /// the transport.
  @override
  void dispose() {
    _logger.info('dispose → cancel subscriptions');
    _disposed = true;
    _messageSub.cancel();
    _textSub.cancel();
    _submitSub.cancel();
    _surfaceSub.cancel();
    _surfaceController.dispose();
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

/// The text of an A2UI client message holding the UI action [name] with
/// [context], as a button tap sends it. The backend treats it as a tap, not
/// as text typed by the user.
String actionMessage(String name, Map<String, Object?> context) => jsonEncode({
  'version': 'v0.9',
  'action': {'name': name, 'context': context},
});

/// Reads the error report in [message], which genui sends through `onSubmit`
/// when it can't draw a surface, as JSON text like `{"error": ...}`.
///
/// Returns `null` when [message] is not an error report (e.g. a tap).
String? errorReportFrom(ChatMessage message) {
  for (final UiInteractionPart part in message.parts.uiInteractionParts) {
    try {
      if (jsonDecode(part.interaction) case {'error': _}) {
        return part.interaction;
      }
    } on FormatException {
      // Not JSON: not an error report.
    }
  }
  return null;
}

/// A UI action from a surface: its name and the values in its context.
typedef UserAction = ({String name, Map<String, Object?> context});

/// Reads the UI action in [message], a tap that genui's `onSubmit` reports.
///
/// The tap arrives as a chat message whose UI interaction parts hold the
/// action as JSON text. Returns `null` when no part holds an action (e.g. an
/// error report).
UserAction? userActionFrom(ChatMessage message) {
  for (final UiInteractionPart part in message.parts.uiInteractionParts) {
    try {
      if (jsonDecode(part.interaction) case {
        'action': {'name': final String name, 'context': final Object? context},
      }) {
        return (
          name: name,
          context: context is Map ? context.cast<String, Object?>() : {},
        );
      }
    } on FormatException {
      // Not JSON: not an action.
    }
  }
  return null;
}
