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

// Tests for the dashboard's round icon buttons, such as Start over.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/widgets/dashboard/circle_icon_button.dart';

/// Shows [child] on a plain screen.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('tapping calls onTap', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      CircleIconButton(
        icon: Icons.restart_alt_rounded,
        tooltip: 'Start over',
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.byTooltip('Start over'));
    expect(taps, 1);
  });

  testWidgets('without onTap it is off', (tester) async {
    await _pump(
      tester,
      const CircleIconButton(
        icon: Icons.restart_alt_rounded,
        tooltip: 'Start over',
        onTap: null,
      ),
    );
    final IconButton button = tester.widget(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('it is at least 44 big to touch', (tester) async {
    await _pump(
      tester,
      CircleIconButton(icon: Icons.add, tooltip: 'Add', onTap: () {}),
    );
    final Size size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });
}
