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

// Tests for the BloodSugarInput card: the mg/dL / mmol/L switch, the − / +
// buttons, and dragging or tapping the band.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/blood_sugar_input/widgets/blood_sugar_card.dart';
import 'package:vitalloop/catalog/blood_sugar_input/widgets/glucose_band.dart';
import 'package:vitalloop/models/vitals/blood_sugar.dart';

import '../../support/test_utils.dart';

/// Shows a [BloodSugarCard] for [valueMgDl] and returns every value it
/// reports.
Future<List<double>> _pumpCard(
  WidgetTester tester, {
  double valueMgDl = defaultGlucoseMgDl,
}) async {
  final changes = <double>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BloodSugarCard(valueMgDl: valueMgDl, onChanged: changes.add),
        ),
      ),
    ),
  );
  return changes;
}

void main() {
  setUpTestEnvironment();

  testWidgets('shows the reading, the normal range and the status', (
    tester,
  ) async {
    await _pumpCard(tester);
    expect(find.text('98'), findsOneWidget);
    expect(find.text('Normal 70–140 mg/dL'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);

    for (final (double value, String status) in [
      (40, 'Low'),
      (160, 'Elevated'),
      (220, 'High'),
    ]) {
      await _pumpCard(tester, valueMgDl: value);
      expect(find.text(status), findsOneWidget, reason: '$value mg/dL');
    }
  });

  testWidgets('switching to mmol/L changes the display only', (tester) async {
    final List<double> changes = await _pumpCard(tester);
    await tester.tap(find.text('mmol/L').first);
    await tester.pumpAndSettle();

    expect(find.text('5.4'), findsOneWidget);
    expect(find.text('Normal 3.9–7.8 mmol/L'), findsOneWidget);
    for (final label in ['3.9', '7.8', '11.1']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(changes, isEmpty); // The stored mg/dL value didn't change.
  });

  testWidgets('− and + step by 1 mg/dL, or 0.1 mmol/L', (tester) async {
    final List<double> changes = await _pumpCard(tester);
    await tester.tap(find.byTooltip('Increase'));
    await tester.pumpAndSettle();
    expect(changes.last, 99);
    expect(find.text('99'), findsOneWidget);

    await tester.tap(find.text('mmol/L').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Decrease'));
    await tester.pumpAndSettle();
    expect(find.text('5.4'), findsOneWidget); // 99 mg/dL is 5.5 mmol/L.
  });

  testWidgets('− turns off at the bottom of the range', (tester) async {
    await _pumpCard(tester, valueMgDl: minGlucoseMgDl);
    final IconButton decrease = tester.widget(
      find.widgetWithIcon(IconButton, Icons.remove_rounded),
    );
    expect(decrease.onPressed, isNull);
  });

  testWidgets('dragging the band moves the value and the status', (
    tester,
  ) async {
    final List<double> changes = await _pumpCard(tester);
    final Rect band = tester.getRect(find.byType(GlucoseBand));

    await tester.dragFrom(band.center, Offset(band.width, 0));
    await tester.pumpAndSettle();
    expect(changes.last, maxGlucoseMgDl);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });

  testWidgets('tapping the band jumps to that value', (tester) async {
    final List<double> changes = await _pumpCard(tester);
    final Rect band = tester.getRect(find.byType(GlucoseBand));

    // The band leaves a margin at each end; tap at its start.
    await tester.tapAt(Offset(band.left + GlucoseBand.margin, band.center.dy));
    await tester.pumpAndSettle();
    expect(changes.single, minGlucoseMgDl);
    expect(find.text('Low'), findsOneWidget);
  });

  testWidgets('touch targets are at least 40 px', (tester) async {
    await _pumpCard(tester);
    for (final IconData icon in [Icons.remove_rounded, Icons.add_rounded]) {
      final Size size = tester.getSize(find.widgetWithIcon(IconButton, icon));
      expect(size.width, greaterThanOrEqualTo(40));
      expect(size.height, greaterThanOrEqualTo(40));
    }
    expect(
      tester.getSize(find.byType(GlucoseBand)).height,
      greaterThanOrEqualTo(40),
    );
  });
}
