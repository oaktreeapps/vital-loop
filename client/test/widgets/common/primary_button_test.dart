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

// Tests for the app's main button.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/widgets/common/primary_button.dart';

import '../../support/test_utils.dart';

/// Shows [child] on a plain screen.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  setUpTestEnvironment();

  testWidgets('tapping it calls onPressed', (tester) async {
    var taps = 0;
    await _pump(tester, PrimaryButton(label: 'Save', onPressed: () => taps++));
    await tester.tap(find.text('Save'));
    expect(taps, 1);
  });

  testWidgets('without onPressed it is off', (tester) async {
    await _pump(tester, const PrimaryButton(label: 'Save', onPressed: null));
    expect(isEnabled(tester, 'Save'), isFalse);
  });

  testWidgets('busy: a spinner instead of the label, and taps do nothing', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      PrimaryButton(label: 'Save', busy: true, onPressed: () => taps++),
    );
    expect(find.text('Save'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 0);
  });
}
