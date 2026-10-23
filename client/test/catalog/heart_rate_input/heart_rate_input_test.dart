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

// Tests for the HeartRateInput card: dragging the ECG strip, the − / +
// buttons, the pulse button and the beating heart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/heart_rate_input/widgets/ecg_strip.dart';
import 'package:vitalloop/catalog/heart_rate_input/widgets/heart_rate_card.dart';
import 'package:vitalloop/models/vitals/heart_rate.dart';

import '../../support/test_utils.dart';

/// Shows a [HeartRateCard] for [bpm] and returns every value it reports.
Future<List<int>> _pumpCard(
  WidgetTester tester, {
  int bpm = defaultBpm,
  bool reduceMotion = false,
}) async {
  final changes = <int>[];
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: HeartRateCard(bpm: bpm, onChanged: changes.add),
          ),
        ),
      ),
    ),
  );
  return changes;
}

void main() {
  setUpTestEnvironment();

  testWidgets('shows the reading, the beat time and the status', (
    tester,
  ) async {
    await _pumpCard(tester);
    expect(find.text('72'), findsOneWidget);
    expect(find.text('833 ms\nbetween beats'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);

    await _pumpCard(tester, bpm: 55);
    expect(find.text('Low'), findsOneWidget);

    await _pumpCard(tester, bpm: 110);
    expect(find.text('High'), findsOneWidget);
  });

  testWidgets('dragging the strip right raises the heart rate', (tester) async {
    final List<int> changes = await _pumpCard(tester);
    // 3 px per bpm: 120 px is 40 bpm.
    await tester.timedDrag(
      find.byType(EcgStrip),
      const Offset(120, 0),
      const Duration(milliseconds: 600),
    );
    await tester.pump();

    expect(changes.last, 112);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('536 ms\nbetween beats'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(changes.toSet(), hasLength(changes.length)); // Each once.
  });

  testWidgets('− and + step by 1 bpm', (tester) async {
    final List<int> changes = await _pumpCard(tester);
    await tester.tap(find.byTooltip('Increase'));
    await tester.pump();
    await tester.tap(find.byTooltip('Decrease'));
    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();
    expect(changes, [73, 72, 71]);
  });

  testWidgets('the pulse button counts taps, then resets', (tester) async {
    await _pumpCard(tester);
    expect(find.text('Tap with your pulse'), findsOneWidget);

    await tester.tap(find.text('Tap with your pulse'));
    await tester.pump();
    expect(find.text('Keep tapping · 1'), findsOneWidget);
    await tester.tap(find.text('Keep tapping · 1'));
    await tester.pump();
    expect(find.text('Keep tapping · 2'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3200));
    expect(find.text('Tap with your pulse'), findsOneWidget);
  });

  testWidgets('the heart beats once per beat, unless motion is reduced', (
    tester,
  ) async {
    await _pumpCard(tester);
    expect(tester.binding.hasScheduledFrame, isTrue);

    await _pumpCard(tester, reduceMotion: true);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('touch targets are at least 40 px', (tester) async {
    await _pumpCard(tester);
    for (final Finder finder in [
      find.byTooltip('Increase'),
      find.byTooltip('Decrease'),
      find.byType(OutlinedButton),
      find.byType(EcgStrip),
    ]) {
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(40));
    }
  });
}
