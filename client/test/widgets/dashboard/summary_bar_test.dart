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

// Tests for the dashboard's "Generate summary" bar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/widgets/dashboard/summary_bar.dart';

import '../../support/test_utils.dart';

/// Shows [bar] at the bottom of a screen, like the dashboard.
Future<void> _pump(WidgetTester tester, SummaryBar bar) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(bottomNavigationBar: bar)));

void main() {
  setUpTestEnvironment();

  testWidgets('nothing logged: a hint, and the button is off', (tester) async {
    await _pump(tester, SummaryBar(entryCount: 0, onPressed: () {}));
    expect(find.text("Log something to generate today's summary"), findsOne);
    expect(isEnabled(tester, 'Generate summary'), isFalse);
  });

  for (final (int count, String label) in [
    (1, 'Generate summary · 1 entry'),
    (3, 'Generate summary · 3 entries'),
  ]) {
    testWidgets('$count logged: "$label"', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        SummaryBar(entryCount: count, onPressed: () => taps++),
      );
      await tester.tap(find.text(label));
      expect(taps, 1);
    });
  }
}
