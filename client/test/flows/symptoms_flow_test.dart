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

// Widget tests for the symptoms flow: picking symptoms, the details step
// with the severity wheel, and the summary.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/severity_input/widgets/severity_scale.dart';
import 'package:vitalloop/flows/symptoms_flow.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';

import '../support/fake_backend.dart';
import '../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  testWidgets('Symptoms on the dashboard opens the symptoms flow', (
    tester,
  ) async {
    useLargeScreen(tester);
    await pumpDashboard(tester);
    await scrollAndTap(tester, find.text('Symptoms'));
    await settle(tester);

    expect(find.byType(TrackingFlowScreen), findsOneWidget);
    expect(find.text('What are you feeling?'), findsOneWidget);
  });

  testWidgets('picked and typed symptoms and severity reach the summary', (
    tester,
  ) async {
    useLargeScreen(tester);
    final backend = FakeBackend('symptoms');
    await pumpFlow(tester, symptomsFlow, backend);

    // Step 1: Continue needs a picked or a typed symptom.
    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(isEnabled(tester, 'Continue'), isFalse);
    await tester.enterText(find.byType(TextField), 'Chills');
    await settle(tester);
    expect(isEnabled(tester, 'Continue'), isTrue);
    await scrollAndTap(tester, find.text('Headache'));
    await scrollAndTap(tester, find.text('Nausea'));
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    expect(backend.actions.first['name'], 'symptomsSelected');

    // Step 2: the picked and typed symptoms, merged.
    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Headache, Nausea, Chills'), findsOneWidget);
    expect(find.text('Moderate'), findsOneWidget); // Starts at 5.

    await tester.enterText(
      find.byType(TextField),
      'Throbbing, behind the eyes',
    );
    await settle(tester);

    // Dragging the severity scale to the right raises it to "Severe".
    final Finder scale = find.byType(SeverityScale);
    await tester.ensureVisible(scale);
    final Rect bounds = tester.getRect(scale);
    await tester.dragFrom(
      bounds.center,
      Offset(bounds.width * 0.25, 0), // From 5 to the 8th segment.
    );
    await settle(tester);
    expect(find.text('Severe'), findsOneWidget);

    await scrollAndTap(tester, button('Save symptoms'));
    await settle(tester);

    final Map<String, Object?> action = backend.actions.last;
    expect(action['name'], 'symptomDetailsEntered');
    final context = action['context']! as Map<String, Object?>;
    expect(context['symptoms'], ['Headache', 'Nausea', 'Chills']);
    expect(context['description'], 'Throbbing, behind the eyes');
    expect(context['severity'], 8);
    expect(
      context['startedAt'],
      matches(RegExp(r'^\d{4}-\d\d-\d\dT\d\d:\d\d:00')),
    );

    // Step 3: the summary.
    expect(find.text('Symptoms saved'), findsOneWidget);
    expect(find.text('Headache, Nausea, Chills'), findsOneWidget);
    expect(find.text('${context['severity']} / 10'), findsOneWidget);
    expect(find.text('Throbbing, behind the eyes'), findsOneWidget);
  });
}
