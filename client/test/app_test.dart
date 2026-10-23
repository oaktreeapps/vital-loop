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

// Tests for the app's start: with a working key it opens on the dashboard,
// which lists every flow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/main.dart';
import 'package:vitalloop/screens/dashboard_screen.dart';

import 'support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  testWidgets('with a working key, the app opens on the dashboard', (
    tester,
  ) async {
    // A phone-sized screen, so every option card is laid out.
    useLargeScreen(tester, size: const Size(1170, 2532), devicePixelRatio: 3);

    await tester.pumpWidget(VitalLoopApp(keySetup: WorkingKeySetup()));
    await tester.pump(); // The key check runs after the first frame.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('What would you like to log today?'), findsOneWidget);
    for (final title in [
      'Pain',
      'Symptoms',
      'Vitals',
      'Medications',
      'Food & nutrition',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget);
    }
  });
}
