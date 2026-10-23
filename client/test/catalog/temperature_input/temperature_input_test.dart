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

// Tests for the TemperatureInput card: the °C / °F switch, and dragging or
// tapping the thermometer.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/temperature_input/widgets/temperature_card.dart';
import 'package:vitalloop/catalog/temperature_input/widgets/thermometer.dart';
import 'package:vitalloop/models/vitals/temperature.dart';

import '../../support/test_utils.dart';

/// Shows a [TemperatureCard] for [tempC] and returns every value it reports.
Future<List<double>> _pumpCard(
  WidgetTester tester, {
  double tempC = defaultTempC,
}) async {
  final changes = <double>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TemperatureCard(tempC: tempC, onChanged: changes.add),
        ),
      ),
    ),
  );
  return changes;
}

void main() {
  setUpTestEnvironment();

  testWidgets('shows the reading and its status', (tester) async {
    await _pumpCard(tester);
    expect(find.text('36.6'), findsOneWidget);
    expect(find.text('°C'), findsWidgets);
    expect(find.text('Normal'), findsOneWidget);

    await _pumpCard(tester, tempC: 38.5);
    expect(find.text('Fever'), findsOneWidget);

    await _pumpCard(tester, tempC: 34.5);
    expect(find.text('Low'), findsOneWidget);
  });

  testWidgets('switching to °F changes the display only', (tester) async {
    final List<double> changes = await _pumpCard(tester);
    await tester.tap(find.text('°F'));
    await tester.pumpAndSettle();

    expect(find.text('97.9'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(changes, isEmpty); // The stored °C value didn't change.
  });

  testWidgets('dragging along the tube sets the temperature', (tester) async {
    final List<double> changes = await _pumpCard(tester);
    final Rect tube = tester.getRect(find.byType(Thermometer));

    // All the way to the right: the top of the range, a fever.
    await tester.dragFrom(
      tube.centerLeft + const Offset(60, 0),
      Offset(tube.width, 0),
    );
    await tester.pumpAndSettle();
    expect(changes.last, maxTempC);
    expect(find.text('42.0'), findsOneWidget);
    expect(find.text('Fever'), findsOneWidget);

    // Every reported value is rounded to 0.1 °C.
    for (final value in changes) {
      expect((value * 10).roundToDouble() / 10, value);
    }
  });

  testWidgets('tapping the tube jumps to that temperature', (tester) async {
    final List<double> changes = await _pumpCard(tester);
    final Rect tube = tester.getRect(find.byType(Thermometer));

    await tester.tapAt(
      Offset(tube.left + Thermometer.xOf(38, tube.width), tube.center.dy),
    );
    await tester.pumpAndSettle();
    expect(changes.single, 38.0);
    expect(find.text('Elevated'), findsOneWidget);
  });

  testWidgets('the thermometer is at least 44 high to touch', (tester) async {
    await _pumpCard(tester);
    expect(
      tester.getSize(find.byType(Thermometer)).height,
      greaterThanOrEqualTo(44),
    );
  });
}
