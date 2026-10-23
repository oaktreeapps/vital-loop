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

// Tests for the app's routes: opening screens by path, going back, and the
// Gemini key check in front of every route.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/core/router/app_routes.dart';
import 'package:vitalloop/main.dart';
import 'package:vitalloop/screens/catalog_screen.dart';
import 'package:vitalloop/screens/dashboard_screen.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';
import 'package:vitalloop/services/gemini_key_setup.dart';

import '../../support/fake_backend.dart';
import '../../support/test_utils.dart';

/// A server with no Gemini API key yet.
class _MissingKeySetup extends WorkingKeySetup {
  @override
  Future<GeminiKeyStatus> status() async =>
      const GeminiKeyStatus(state: GeminiKeyState.missing);
}

/// Starts the app on [location].
Future<void> _open(
  WidgetTester tester,
  String location, {
  GeminiKeySetup? keySetup,
}) async {
  await tester.pumpWidget(
    VitalLoopApp(
      keySetup: keySetup ?? WorkingKeySetup(),
      transportFor: (flow) => FakeBackend(flow.name),
      initialLocation: location,
    ),
  );
  await settle(tester);
}

/// The flow shown right now, if any.
String? _shownFlow(WidgetTester tester) {
  final Finder screen = find.byType(TrackingFlowScreen);
  if (screen.evaluate().isEmpty) return null;
  return tester.widget<TrackingFlowScreen>(screen).flow.name;
}

void main() {
  setUpTestEnvironment();

  testWidgets('a flow path opens that flow, with the dashboard behind it', (
    tester,
  ) async {
    useLargeScreen(tester);
    await _open(tester, AppRoutes.flow('vitals'));
    expect(_shownFlow(tester), 'vitals');

    // Back (the system back button) returns to the dashboard.
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(_shownFlow(tester), isNull);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('tapping an option opens its flow', (tester) async {
    useLargeScreen(tester);
    await pumpDashboard(tester);
    await tester.tap(find.text('Pain'));
    await settle(tester);
    expect(_shownFlow(tester), 'pain');
  });

  testWidgets('the summary path opens the daily summary', (tester) async {
    useLargeScreen(tester);
    await _open(tester, AppRoutes.summary);
    expect(_shownFlow(tester), 'daily_summary');
  });

  testWidgets('the catalog path opens the component catalog', (tester) async {
    useLargeScreen(tester, size: const Size(1080, 2400));
    await _open(tester, AppRoutes.catalog);
    expect(find.byType(CatalogScreen), findsOneWidget);
  });

  testWidgets('an unknown flow goes to the dashboard', (tester) async {
    useLargeScreen(tester);
    await _open(tester, AppRoutes.flow('nope'));
    expect(_shownFlow(tester), isNull);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('a direct link to a flow still asks for a missing key', (
    tester,
  ) async {
    useLargeScreen(tester);
    await _open(tester, AppRoutes.flow('pain'), keySetup: _MissingKeySetup());
    expect(find.text('Add your Gemini API key'), findsOneWidget);
  });
}
