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

// Tests for the SeverityInput card: dragging and tapping the scale, and the
// face that follows the value.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/severity_input/widgets/severity_card.dart';
import 'package:vitalloop/catalog/severity_input/widgets/severity_face.dart';
import 'package:vitalloop/catalog/severity_input/widgets/severity_scale.dart';
import 'package:vitalloop/models/severity_level.dart';

import '../../support/test_utils.dart';

/// Shows a [SeverityCard] for [value] and returns every value it reports.
Future<List<int>> _pumpCard(
  WidgetTester tester, {
  int value = defaultSeverity,
}) async {
  final changes = <int>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SeverityCard(
            label: 'Severity',
            value: value,
            onChanged: changes.add,
          ),
        ),
      ),
    ),
  );
  return changes;
}

/// The number [n] in the scale's row of numbers.
Finder _number(int n) =>
    find.descendant(of: find.byType(SeverityScale), matching: find.text('$n'));

void main() {
  setUpTestEnvironment();

  testWidgets('shows the number, its meaning, band and face', (tester) async {
    for (final (int value, String band) in [
      (2, 'Mild'),
      (5, 'Moderate'),
      (8, 'Severe'),
      (10, 'Worst'),
    ]) {
      await _pumpCard(tester, value: value);
      await tester.pumpAndSettle();
      expect(find.text(band), findsOneWidget, reason: '$value');
      expect(find.text(severityDescription(value)), findsOneWidget);
      final SeverityFace face = tester.widget(find.byType(SeverityFace));
      expect(face.severity, value);
      expect(face.color, SeverityLevel.of(value).color);
    }
  });

  testWidgets('tapping a number jumps to it', (tester) async {
    final List<int> changes = await _pumpCard(tester);
    await tester.tap(_number(9));
    await tester.pumpAndSettle();

    expect(changes, [9]);
    expect(find.text('Severe'), findsOneWidget);
    expect(find.text('Unable to do anything'), findsOneWidget);
  });

  testWidgets('dragging across the scale fills it, reporting each value once', (
    tester,
  ) async {
    final List<int> changes = await _pumpCard(tester, value: 1);
    final Rect scale = tester.getRect(find.byType(SeverityScale));

    // From the first segment to past the end.
    await tester.timedDragFrom(
      scale.centerLeft + const Offset(4, 0),
      Offset(scale.width, 0),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();

    expect(changes.last, maxSeverity);
    expect(changes.toSet(), hasLength(changes.length)); // Each once.
    expect(find.text('Worst'), findsOneWidget);
  });

  testWidgets('touch targets: numbers 28 px high, scale 92 px', (tester) async {
    await _pumpCard(tester);
    expect(tester.getSize(find.byType(SeverityScale)).height, 92);
    final Finder numberButton = find.ancestor(
      of: _number(3),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(numberButton).height, greaterThanOrEqualTo(28));
  });
}
