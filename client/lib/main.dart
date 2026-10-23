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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import 'core/app_logging.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/gemini_key_gate.dart';
import 'screens/tracking_flow_screen.dart';
import 'services/gemini_key_setup.dart';

/// Logger for app start-up messages.
final Logger _logger = Logger('main');

/// Starts the app: turns on logging, then shows [VitalLoopApp].
void main() {
  setupLogging();
  _logger.info('main() → runApp(VitalLoopApp)');
  runApp(const VitalLoopApp());
}

/// The root widget of the VitalLoop app.
///
/// It sets up the Material theme and the router ([createAppRouter]), which
/// opens on the [DashboardScreen], where the user picks what to track. A
/// [GeminiKeyGate] around every screen first makes sure the server has a
/// working Gemini API key, and asks for one if not.
class VitalLoopApp extends StatefulWidget {
  /// Creates the app.
  ///
  /// [keySetup] checks the server's Gemini API key; it defaults to
  /// [HttpGeminiKeySetup]. [transportFor] is how flows reach the server; it
  /// defaults to the real server. The app opens on [initialLocation]. Tests
  /// pass their own.
  const VitalLoopApp({
    super.key,
    this.keySetup,
    this.transportFor,
    this.initialLocation = AppRoutes.dashboard,
  });

  /// How the app checks and sends the Gemini API key.
  final GeminiKeySetup? keySetup;

  /// How each flow reaches the server.
  final TransportFactory? transportFor;

  /// The path the app opens on, e.g. `/` or `/flow/pain`.
  final String initialLocation;

  @override
  State<VitalLoopApp> createState() => _VitalLoopAppState();
}

/// Holds the router, so it outlives rebuilds of the app.
class _VitalLoopAppState extends State<VitalLoopApp> {
  /// The navigator the screens live in; the key check shows its dialogs
  /// there.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Moves between the screens; see [AppRoutes].
  late final GoRouter _router = createAppRouter(
    navigatorKey: _navigatorKey,
    transportFor: widget.transportFor,
    initialLocation: widget.initialLocation,
  );

  /// The app's theme. Light only: the dashboard and the screens' JSON
  /// themes use a light, warm palette.
  static final ThemeData _theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VitalLoop',
      theme: _theme,
      routerConfig: _router,
      // Around every screen, so a link straight to a flow is checked too.
      builder: (context, child) => GeminiKeyGate(
        setup: widget.keySetup,
        navigatorKey: _navigatorKey,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
