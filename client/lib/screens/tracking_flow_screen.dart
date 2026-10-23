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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../core/router/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/care_place.dart';
import '../models/health_log.dart';
import '../models/tracking_flow.dart';
import '../services/backend_transport.dart';
import '../services/genui_session.dart';
import '../widgets/flow/care_city_dialog.dart';
import '../widgets/flow/flow_body.dart';

/// Creates the [Transport] for a flow's session.
typedef TransportFactory = Transport Function(TrackingFlow flow);

/// A guided tracking flow (e.g. Food / Nutrition, Medications), rendered
/// entirely from genui surfaces.
///
/// Flow: TrackingFlowScreen → GenUiSession (the flow's catalog) →
/// BackendTransport → the flow's agent on the Python backend. The backend
/// answers each step with a new surface; this screen always shows the latest
/// one.
class TrackingFlowScreen extends StatefulWidget {
  /// Creates a screen that runs [flow].
  const TrackingFlowScreen({super.key, required this.flow, this.transportFor});

  /// The flow to run: its components and the request that starts it.
  final TrackingFlow flow;

  /// Overrides the backend; used by tests.
  final TransportFactory? transportFor;

  /// Creates the state that owns the flow's [GenUiSession].
  @override
  State<TrackingFlowScreen> createState() => _TrackingFlowScreenState();
}

/// State of [TrackingFlowScreen]: runs the flow's [GenUiSession], saves the
/// answers to [healthLog], and shows the latest surface.
class _TrackingFlowScreenState extends State<TrackingFlowScreen> {
  /// Logger for this screen's messages.
  static final Logger _log = Logger('TrackingFlowScreen');

  /// The running session. Replaced with a new one by [_restart].
  late GenUiSession _session;

  /// Listens to the session's [GenUiSession.actions], see [_onAction].
  StreamSubscription<UserAction>? _actionsSub;

  /// The answers from this flow's actions so far; saved to [healthLog] as
  /// one entry on the flow's save action.
  final Map<String, Object?> _answers = {};

  /// The last city searched for care nearby; the city dialog starts with it.
  String _careCity = defaultCareCity;

  /// Starts the flow as soon as the screen opens.
  @override
  void initState() {
    super.initState();
    _startSession();
  }

  /// Creates a new [GenUiSession] for the flow and sends its start message.
  ///
  /// Uses [TrackingFlowScreen.transportFor] if given, otherwise a
  /// [BackendTransport] for the flow.
  void _startSession() {
    final TrackingFlow flow = widget.flow;
    final Transport transport =
        widget.transportFor?.call(flow) ??
        BackendTransport(flowName: flow.name);
    _log.info(
      'TrackingFlowScreen → GenUiSession (${flow.name} catalog, '
      '${flow.catalog.items.length} components, ${transport.runtimeType})',
    );
    _session = GenUiSession(transport: transport, catalog: flow.catalog);
    _answers.clear();
    _actionsSub = _session.actions.listen(_onAction);
    _log.info('Kick off flow → sendMessage(start message)');
    // The daily summary's start message holds every entry: FINEST only.
    _log.finest(() => 'Start message: ${flow.startMessage}');
    unawaited(_session.sendMessage(flow.startMessage));
  }

  /// Handles an action from a surface.
  ///
  /// [goToDashboardAction] closes the flow, [finishAction] also clears
  /// today's log to start again, and [chooseCareCityAction] asks for a city
  /// to find care near. Any other action adds its values to
  /// [_answers]; when the flow says the action saves an entry, the entry is
  /// added to [healthLog] and the answers start over.
  void _onAction(UserAction action) {
    if (action.name == goToDashboardAction) {
      _log.info('$goToDashboardAction → back to the dashboard');
      context.go(AppRoutes.dashboard);
      return;
    }
    if (action.name == finishAction) {
      _log.info('$finishAction → clear the log, back to the dashboard');
      healthLog.clear();
      context.go(AppRoutes.dashboard);
      return;
    }
    if (action.name == chooseCareCityAction) {
      unawaited(_findCareNearby());
      return;
    }
    _answers.addAll(action.context);
    final HealthLogEntry? entry = widget.flow.entryFor(action.name, _answers);
    if (entry == null) return;
    _log.info('${action.name} → healthLog.add (${entry.category})');
    healthLog.add(entry);
    _answers.clear();
  }

  /// Asks for a city in a [CareCityDialog], then asks the backend for care
  /// near it ([findNearbyCareAction]). Nothing happens if the dialog is
  /// dismissed.
  Future<void> _findCareNearby() async {
    _log.info('$chooseCareCityAction → ask for a city');
    final String? city = await showDialog<String>(
      context: context,
      // Over this screen's navigator, so it stays inside the app when the
      // app is embedded in a page (the showcase website's phone).
      useRootNavigator: false,
      builder: (_) => CareCityDialog(initialCity: _careCity),
    );
    if (!mounted || city == null) return;
    _careCity = city;
    // The city is where the user looks for care: FINE only.
    _log.fine('City chosen: $city');
    await _session.sendAction(findNearbyCareAction, {'city': city});
  }

  /// Throws away the current session and starts the flow again. Used by the
  /// "Start over" button after an error.
  void _restart() {
    _log.info('Start over → dispose session and start again');
    unawaited(_actionsSub?.cancel());
    _session.dispose();
    _startSession();
    setState(() {});
  }

  /// Stops listening to actions and closes the session.
  @override
  void dispose() {
    _log.info('dispose → GenUiSession.dispose');
    unawaited(_actionsSub?.cancel());
    _session.dispose();
    super.dispose();
  }

  /// Builds the page and rebuilds its body whenever the session changes.
  @override
  Widget build(BuildContext context) {
    // No app bar: each screen's JSON draws its own header. Back is the
    // system back button / gesture.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _session,
            builder: (context, _) => FlowBody(
              session: _session,
              loadingLabel: widget.flow.loadingLabel,
              onRetry: _restart,
            ),
          ),
        ),
      ),
    );
  }
}
