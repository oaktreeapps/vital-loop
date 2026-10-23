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

// Tests for the BloodPressureInput card: the reading and its status, and
// dragging the systolic and diastolic rulers.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/blood_pressure_input/widgets/blood_pressure_card.dart';
import 'package:vitalloop/catalog/blood_pressure_input/widgets/ruler_picker.dart';
import 'package:vitalloop/models/vitals/blood_pressure.dart';

import '../../support/test_utils.dart';

/// Shows a [BloodPressureCard] for [systolic] / [diastolic] and returns
/// every reading it reports.
Future<List<(int, int)>> _pumpCard(
  WidgetTester tester, {
  int systolic = defaultSystolic,
  int diastolic = defaultDiastolic,
}) async {
  final changes = <(int, int)>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BloodPressureCard(
            systolic: systolic,
            diastolic: diastolic,
            onChanged: (s, d) => changes.add((s, d)),
          ),
        ),
      ),
    ),
  );
  return changes;
}

/// The systolic (first) or diastolic (second) ruler.
Finder _ruler(int index) => find.byType(RulerPicker).at(index);

void main() {
  setUpTestEnvironment();

  testWidgets('shows the reading and its status', (tester) async {
    await _pumpCard(tester);
    expect(find.text('118 / 76'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('SYS'), findsOneWidget);
    expect(find.text('DIA'), findsOneWidget);

    await _pumpCard(tester, systolic: 145, diastolic: 93);
    expect(find.text('145 / 93'), findsOneWidget);
    expect(find.text('High · stage 2'), findsOneWidget);
  });

  testWidgets('dragging left raises the value, 8 px per mmHg', (tester) async {
    final List<(int, int)> changes = await _pumpCard(tester);
    // A slow drag, so the ruler doesn't glide on afterwards.
    await tester.timedDrag(
      _ruler(0),
      const Offset(-8.0 * 14, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(changes.last, (132, 76));
    expect(find.text('132 / 76'), findsOneWidget);
    expect(find.text('High · stage 1'), findsOneWidget);
    // One report per mmHg on the way.
    expect(changes.map((change) => change.$1), [
      for (var sys = 119; sys <= 132; sys++) sys,
    ]);
  });

  testWidgets('dragging right lowers the value, down to the minimum', (
    tester,
  ) async {
    final List<(int, int)> changes = await _pumpCard(tester);
    await tester.timedDrag(
      _ruler(1),
      const Offset(8.0 * 100, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(changes.last, (118, minDiastolic));
    expect(find.text('Low'), findsOneWidget);
  });

  testWidgets('a quick swipe glides on past the finger', (tester) async {
    final List<(int, int)> changes = await _pumpCard(tester);
    await tester.fling(_ruler(0), const Offset(-120, 0), 1000);
    await tester.pumpAndSettle();

    // The finger moved 120 px (15 mmHg); the glide carries it further.
    expect(changes.last.$1, greaterThan(118 + 15));
    expect(changes.last.$1, lessThanOrEqualTo(maxSystolic));
  });

  testWidgets('screen readers can step the rulers', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final List<(int, int)> changes = await _pumpCard(tester);
    final SemanticsNode node = tester.getSemantics(_ruler(0));
    expect(node.value, '118');

    node.owner!.performAction(node.id, SemanticsAction.increase);
    await tester.pump();
    expect(changes.single, (119, 76));
    semantics.dispose();
  });

  testWidgets('the rulers are 52 px high to touch', (tester) async {
    await _pumpCard(tester);
    expect(tester.getSize(_ruler(0)).height, RulerPicker.height);
  });
}
