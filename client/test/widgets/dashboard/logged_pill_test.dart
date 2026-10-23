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

// Tests for the dashboard's "logged" pill and count badge.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/widgets/dashboard/count_badge.dart';
import 'package:vitalloop/widgets/dashboard/logged_pill.dart';

import '../../support/test_utils.dart';

/// Shows [child] on a plain screen.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  setUpTestEnvironment();

  testWidgets('the pill says how many entries were logged', (tester) async {
    await _pump(tester, const LoggedPill(2));
    expect(find.text('2 logged'), findsOneWidget);
  });

  testWidgets('the badge shows the count', (tester) async {
    await _pump(tester, const CountBadge(4));
    expect(find.text('4'), findsOneWidget);
  });
}
