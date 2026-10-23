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

// Tests for the dialog that asks before clearing today's log.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/widgets/dashboard/start_over_dialog.dart';

import '../../support/test_utils.dart';

/// Opens the dialog for [count] entries; the returned function reads what it
/// closed with.
Future<bool? Function()> _open(WidgetTester tester, int count) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showDialog<bool>(
            context: context,
            builder: (_) => StartOverDialog(entryCount: count),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return () => result;
}

void main() {
  setUpTestEnvironment();

  testWidgets('it says how many entries will be cleared', (tester) async {
    await _open(tester, 3);
    expect(find.text('Clear today’s log?'), findsOneWidget);
    expect(find.textContaining('the 3 entries you logged'), findsOneWidget);
  });

  testWidgets('one entry reads "1 entry"', (tester) async {
    await _open(tester, 1);
    expect(find.textContaining('the 1 entry you logged'), findsOneWidget);
  });

  for (final (String label, bool? result) in [
    ('Start over', true),
    ('Keep my entries', false),
  ]) {
    testWidgets('"$label" closes it with $result', (tester) async {
      final bool? Function() closedWith = await _open(tester, 2);
      await tester.tap(button(label));
      await tester.pumpAndSettle();
      expect(find.byType(StartOverDialog), findsNothing);
      expect(closedWith(), result);
    });
  }
}
