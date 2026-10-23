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

// Tests for the dashboard: the greeting follows the time of day, the catalog
// button opens the catalog, and Start over clears the log after asking.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/health_log.dart';
import 'package:vitalloop/screens/catalog_screen.dart';
import 'package:vitalloop/screens/dashboard_screen.dart';

import '../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  test('greeting follows the time of day', () {
    expect(greetingFor(DateTime(2026, 1, 1, 8)), 'Good morning');
    expect(greetingFor(DateTime(2026, 1, 1, 13)), 'Good afternoon');
    expect(greetingFor(DateTime(2026, 1, 1, 19)), 'Good evening');
    expect(greetingFor(DateTime(2026, 1, 1, 2)), 'Good evening');
  });

  testWidgets('the catalog button opens the component catalog', (tester) async {
    // Same size as the catalog screen test: genui's AudioPlayer preview
    // needs a little more width with the wide test font.
    useLargeScreen(tester, size: const Size(1080, 2400));
    await pumpDashboard(tester);

    await tester.tap(find.byTooltip('Component catalog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CatalogScreen), findsOneWidget);
  });

  group('start over', () {
    /// Logs two entries, opens the dashboard and taps Start over.
    Future<void> openDialog(WidgetTester tester) async {
      useLargeScreen(tester, size: const Size(1080, 2400));
      for (final flow in ['pain', 'vitals']) {
        healthLog.add(
          HealthLogEntry(
            flowName: flow,
            category: flow,
            icon: 'body',
            details: '$flow entry',
            loggedAt: DateTime(2026, 9, 26, 9, 30),
          ),
        );
      }
      await pumpDashboard(tester);
      expect(find.text('Generate summary · 2 entries'), findsOneWidget);
      await tester.tap(find.byTooltip('Start over'));
      await tester.pumpAndSettle();
      expect(find.text('Clear today’s log?'), findsOneWidget);
      expect(find.textContaining('the 2 entries you logged'), findsOneWidget);
    }

    testWidgets('clears the log once confirmed', (tester) async {
      await openDialog(tester);
      await tester.tap(button('Start over'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(healthLog.isEmpty, isTrue);
      expect(find.text('Generate summary · 2 entries'), findsNothing);
      expect(find.text('1 logged'), findsNothing);
    });

    testWidgets('keeps the log when cancelled', (tester) async {
      await openDialog(tester);
      await tester.tap(button('Keep my entries'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(healthLog.entries, hasLength(2));
    });

    testWidgets('is off while nothing is logged', (tester) async {
      useLargeScreen(tester, size: const Size(1080, 2400));
      await pumpDashboard(tester);
      final IconButton startOver = tester.widget(
        find.ancestor(
          of: find.byTooltip('Start over'),
          matching: find.byType(IconButton),
        ),
      );
      expect(startOver.onPressed, isNull);
    });
  });
}
