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

// Widget tests for the medication flow: picking or typing a medicine, the
// dose and schedule step, and the shared notes and summary screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/flows/medication_flow.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';

import '../support/fake_backend.dart';
import '../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  testWidgets('Medications on the dashboard opens the medication flow', (
    tester,
  ) async {
    useLargeScreen(tester);
    await pumpDashboard(tester);
    await scrollAndTap(tester, find.text('Medications'));
    await settle(tester);

    expect(find.byType(TrackingFlowScreen), findsOneWidget);
    expect(find.text('Which medicine are you logging?'), findsOneWidget);
  });

  testWidgets('step 1: a typed name wins over the picked chip', (tester) async {
    useLargeScreen(tester);
    final backend = FakeBackend('medication');
    await pumpFlow(tester, medicationFlow, backend);

    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(isEnabled(tester, 'Continue'), isFalse);

    // A picked chip enables Continue.
    await scrollAndTap(tester, find.text('Ibuprofen'));
    await settle(tester);
    expect(isEnabled(tester, 'Continue'), isTrue);

    // A typed name is used instead of the picked one.
    await tester.enterText(find.byType(TextField), 'Omeprazole');
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    final Map<String, Object?> action = backend.actions.single;
    expect(action['name'], 'medicineNameEntered');
    expect(action['context'], {'medicineName': 'Omeprazole'});
  });

  testWidgets('step 1: with nothing typed, the picked chip is sent', (
    tester,
  ) async {
    useLargeScreen(tester);
    final backend = FakeBackend('medication');
    await pumpFlow(tester, medicationFlow, backend);

    await scrollAndTap(tester, find.text('Vitamin D'));
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    expect(backend.actions.single['context'], {'medicineName': 'Vitamin D'});
  });

  testWidgets('step 2: the chosen dosage and scheduled time are sent', (
    tester,
  ) async {
    useLargeScreen(tester);
    final backend = FakeBackend('medication');
    await pumpFlow(tester, medicationFlow, backend);
    await scrollAndTap(tester, find.text('Ibuprofen'));
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.text('About Ibuprofen'), findsOneWidget);
    expect(
      find.textContaining('non-steroidal anti-inflammatory'),
      findsOneWidget,
    );
    expect(find.text('1 tablet'), findsWidgets);
    expect(isEnabled(tester, 'Continue'), isFalse);

    // Slide the dosage to the maximum.
    final Finder slider = find.byType(Slider);
    await tester.ensureVisible(slider);
    await tester.pump();
    final Rect box = tester.getRect(slider);
    await tester.tapAt(Offset(box.right - 12, box.center.dy));
    await settle(tester);
    expect(find.text('10 tablets'), findsWidgets);

    // Pick the scheduled date, then the time, with the pickers' defaults.
    await scrollAndTap(tester, find.text('Select a date and time'));
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(isEnabled(tester, 'Continue'), isTrue);

    await scrollAndTap(tester, button('Continue'));
    await settle(tester);
    final Map<String, Object?> action = backend.actions.last;
    expect(action['name'], 'doseScheduleEntered');
    final context = action['context']! as Map<String, Object?>;
    expect(context['dosage'], 10);
    expect(DateTime.tryParse(context['scheduledAt']! as String), isNotNull);
  });

  testWidgets('step 2: an unknown medicine gets a hint instead', (
    tester,
  ) async {
    useLargeScreen(tester);
    await pumpFlow(tester, medicationFlow, FakeBackend('medication'));
    await tester.enterText(find.byType(TextField), 'Omeprazole');
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    expect(find.text('About Omeprazole'), findsOneWidget);
    expect(
      find.text(
        'No description for this medicine yet. Check the leaflet in the pack.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('steps 3 and 4: notes are saved and shown in the summary', (
    tester,
  ) async {
    useLargeScreen(tester);
    final backend = FakeBackend('medication');
    await pumpFlow(tester, medicationFlow, backend);
    await scrollAndTap(tester, find.text('Cetirizine'));
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);
    await scrollAndTap(tester, find.text('Select a date and time'));
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    // Step 3: the shared notes screen with this flow's pills and action.
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(find.text('Anything else to note?'), findsOneWidget);
    expect(find.text('Cetirizine'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Felt a little drowsy');
    await settle(tester);
    await scrollAndTap(tester, button('Save entry'));
    await settle(tester);
    expect(backend.actions.last['name'], 'saveMedicationEntry');

    // Step 4: the shared summary with this flow's rows.
    expect(find.text('Entry saved'), findsOneWidget);
    expect(find.text('Medicine'), findsOneWidget);
    expect(find.text('Dose & time'), findsOneWidget);
    expect(find.textContaining('1 tablet · '), findsOneWidget);
    expect(find.text('Felt a little drowsy'), findsOneWidget);

    // "Go to dashboard" is handled by the app, not sent to the backend.
    await scrollAndTap(tester, button('Go to dashboard'));
    await settle(tester);
    expect(backend.actions.last['name'], 'saveMedicationEntry');
  });
}
