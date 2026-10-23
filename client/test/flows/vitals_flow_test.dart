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

// Widget tests for the vitals flow: the four reading cards, the
// time, saving and the summary.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/blood_pressure_input/widgets/blood_pressure_card.dart';
import 'package:vitalloop/catalog/blood_sugar_input/widgets/blood_sugar_card.dart';
import 'package:vitalloop/catalog/heart_rate_input/widgets/ecg_strip.dart';
import 'package:vitalloop/catalog/heart_rate_input/widgets/heart_rate_card.dart';
import 'package:vitalloop/catalog/temperature_input/widgets/temperature_card.dart';
import 'package:vitalloop/flows/vitals_flow.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';

import '../support/fake_backend.dart';
import '../support/test_utils.dart';

/// The card of the vital labelled [label].
Finder _card(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is BloodPressureCard ||
        widget is HeartRateCard ||
        widget is TemperatureCard ||
        widget is BloodSugarCard,
  ),
);

void main() {
  setUpTestEnvironment();

  testWidgets('Vitals on the dashboard opens the vitals flow', (tester) async {
    useLargeScreen(tester);
    await pumpDashboard(tester);
    await scrollAndTap(tester, find.text('Vitals'));
    await settle(tester);

    expect(find.byType(TrackingFlowScreen), findsOneWidget);
    expect(find.text('Log your vitals'), findsOneWidget);
  });

  testWidgets('saved readings reach the backend and the summary', (
    tester,
  ) async {
    useLargeScreen(tester);
    final backend = FakeBackend('vitals');
    await pumpFlow(tester, vitalsFlow, backend);

    // The four custom components, all starting in the normal range.
    for (final label in [
      'Blood pressure',
      'Heart rate',
      'Temperature',
      'Blood sugar',
    ]) {
      expect(_card(label), findsOneWidget, reason: label);
    }
    expect(find.text('Normal'), findsNWidgets(4));
    expect(find.text('Measurement time'), findsOneWidget);

    // Dragging the ECG strip right raises the heart rate into "High".
    final Finder ecg = find.descendant(
      of: _card('Heart rate'),
      matching: find.byType(EcgStrip),
    );
    await tester.ensureVisible(ecg);
    await tester.drag(ecg, const Offset(150, 0));
    await settle(tester);
    expect(
      find.descendant(of: _card('Heart rate'), matching: find.text('High')),
      findsOneWidget,
    );

    await scrollAndTap(tester, button('Save readings'));
    await settle(tester);

    final Map<String, Object?> action = backend.actions.single;
    expect(action['name'], 'vitalsEntered');
    final context = action['context']! as Map<String, Object?>;
    expect(context['systolic'], 118);
    expect(context['diastolic'], 76);
    expect(context['heartRate'], greaterThan(100));
    expect(context['temperature'], 36.6);
    expect(context['bloodSugar'], 98);
    // Defaults to now.
    expect(
      context['measuredAt'],
      matches(RegExp(r'^\d{4}-\d\d-\d\dT\d\d:\d\d:00')),
    );

    // The summary shows every reading.
    expect(find.text('Readings saved'), findsOneWidget);
    expect(find.text('118/76 mmHg'), findsOneWidget);
    expect(find.text('${context['heartRate']} bpm'), findsOneWidget);
    expect(find.text('36.6 °C'), findsOneWidget);
    expect(find.text('98 mg/dL'), findsOneWidget);
  });
}
