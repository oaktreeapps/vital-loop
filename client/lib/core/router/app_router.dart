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

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../flows/daily_summary_flow.dart';
import '../../models/health_log.dart';
import '../../models/health_option.dart';
import '../../models/tracking_flow.dart';
import '../../screens/catalog_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/tracking_flow_screen.dart';
import 'app_routes.dart';

/// The tracking flow on the dashboard called [name], or `null` if there is
/// none.
TrackingFlow? _flowNamed(String? name) {
  for (final HealthTrackingOption option in HealthTrackingOption.values) {
    if (option.flow.name == name) return option.flow;
  }
  return null;
}

/// Creates the app's router.
///
/// [navigatorKey] lets widgets above the screens (the Gemini key check)
/// show dialogs. Flows talk to the server through [transportFor], or a
/// `BackendTransport` by default; tests pass their own. The app opens on
/// [initialLocation].
GoRouter createAppRouter({
  required GlobalKey<NavigatorState> navigatorKey,
  TransportFactory? transportFor,
  String initialLocation = AppRoutes.dashboard,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'flow/:name',
            // An unknown flow name goes back to the dashboard.
            redirect: (context, state) =>
                _flowNamed(state.pathParameters['name']) == null
                ? AppRoutes.dashboard
                : null,
            builder: (context, state) => TrackingFlowScreen(
              flow: _flowNamed(state.pathParameters['name'])!,
              transportFor: transportFor,
            ),
          ),
          GoRoute(
            path: 'summary',
            // Summarizes the entries logged so far today.
            builder: (context, state) => TrackingFlowScreen(
              flow: dailySummaryFlow(healthLog.entries),
              transportFor: transportFor,
            ),
          ),
          GoRoute(
            path: 'catalog',
            builder: (context, state) => const CatalogScreen(),
          ),
        ],
      ),
    ],
  );
}
