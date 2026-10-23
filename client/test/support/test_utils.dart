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

// Helpers shared by the widget tests: the common setup, a large test screen,
// pumping a flow or the dashboard with a fake backend, and finding and tapping
// a step's buttons.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalloop/core/router/app_routes.dart';
import 'package:vitalloop/main.dart';
import 'package:vitalloop/models/health_log.dart';
import 'package:vitalloop/models/tracking_flow.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';
import 'package:vitalloop/services/gemini_key_setup.dart';

import 'fake_backend.dart';

/// The server's flow templates, relative to client/, where `flutter test`
/// runs.
const String serverFlowsDir = '../server/flows';

/// The setup every widget test file needs; call it at the top of `main`.
///
/// Turns off font downloads (surface themes use Google Fonts, and tests have
/// no network) and empties the app-wide [healthLog] before each test, so no
/// test sees entries saved by another.
void setUpTestEnvironment() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(healthLog.clear);
}

/// Uses a large test screen for this test and resets it when the test ends.
///
/// The default is wider than a phone: the test font draws every glyph as a
/// full square, so pills and button labels need more room than on a device.
void useLargeScreen(
  WidgetTester tester, {
  Size size = const Size(1600, 3200),
  double devicePixelRatio = 2.5,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.reset);
}

/// A server that already has a working Gemini API key, so the app starts
/// without asking for one.
class WorkingKeySetup implements GeminiKeySetup {
  /// Always answers that the key works.
  @override
  Future<GeminiKeyStatus> status() async =>
      const GeminiKeyStatus(state: GeminiKeyState.ok);

  /// Never called: the key already works.
  @override
  Future<void> submit(String key) async {}

  /// Nothing to free.
  @override
  void close() {}
}

/// Starts the whole app (router, key check) on [location], with flows
/// talking to the backend from [transportFor].
Future<void> _pumpApp(
  WidgetTester tester, {
  required String location,
  required TransportFactory transportFor,
}) async {
  await tester.pumpWidget(
    VitalLoopApp(
      keySetup: WorkingKeySetup(),
      transportFor: transportFor,
      initialLocation: location,
    ),
  );
  // The key check runs after the first frame; let it finish.
  await tester.pump();
  await tester.pump();
}

/// Opens [flow] (at `/flow/<name>`) talking to [backend], and waits for its
/// first screen. The dashboard is underneath, as in the app.
Future<void> pumpFlow(
  WidgetTester tester,
  TrackingFlow flow,
  FakeBackend backend,
) async {
  await _pumpApp(
    tester,
    location: AppRoutes.flow(flow.name),
    transportFor: (_) => backend,
  );
  await settle(tester);
}

/// Shows the dashboard. Each flow it opens talks to the backend from
/// [transportFor], by default a new [FakeBackend] for that flow.
Future<void> pumpDashboard(
  WidgetTester tester, {
  TransportFactory? transportFor,
}) => _pumpApp(
  tester,
  location: AppRoutes.dashboard,
  transportFor: transportFor ?? (flow) => FakeBackend(flow.name),
);

/// Lets the app run for two seconds of fake time (20 frames, 100 ms apart),
/// so the backend's screens arrive and animations finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls [finder] into view, then taps it.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// The step's Button, found by its label.
Finder button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

/// Whether the Button labelled [label] can be tapped right now.
bool isEnabled(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(button(label)).onPressed != null;
