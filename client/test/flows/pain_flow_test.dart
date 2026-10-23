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

// Widget tests for the pain flow: the body map (front and back), the pain
// level wheel, and the shared notes and summary screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/body_map_picker/widgets/body_figure.dart';
import 'package:vitalloop/catalog/severity_input/widgets/severity_scale.dart';
import 'package:vitalloop/flows/pain_flow.dart';
import 'package:vitalloop/models/body_map/body_map.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';

import '../support/fake_backend.dart';
import '../support/test_utils.dart';

/// Taps the body region [id] on the figure: a point inside its outline that
/// no region painted after it covers.
Future<void> _tapRegion(WidgetTester tester, String id) async {
  final Finder figure = find.byKey(bodyFigureKey);
  await tester.ensureVisible(figure);
  await tester.pump();
  final Rect box = tester.getRect(figure);
  final BodyRegion region = selectableRegions[id]!;
  final List<BodyRegion> side = regionsFor(region.view);
  final List<BodyRegion> above = side
      .sublist(side.indexOf(region) + 1)
      .where((r) => !r.decorative)
      .toList();
  final Path path = region.clipper.getClip(box.size);
  final Rect bounds = path.getBounds();
  for (var y = 0.2; y < 1; y += 0.1) {
    for (var x = 0.2; x < 1; x += 0.1) {
      final p = Offset(
        bounds.left + bounds.width * x,
        bounds.top + bounds.height * y,
      );
      if (path.contains(p) &&
          !above.any((r) => r.clipper.getClip(box.size).contains(p))) {
        await tester.tapAt(box.topLeft + p);
        await tester.pump();
        return;
      }
    }
  }
  fail('No tappable point found for $id');
}

void main() {
  setUpTestEnvironment();

  testWidgets('Pain on the dashboard opens the pain flow', (tester) async {
    useLargeScreen(tester);
    await pumpDashboard(tester);
    await scrollAndTap(tester, find.text('Pain'));
    await settle(tester);

    expect(find.byType(TrackingFlowScreen), findsOneWidget);
    expect(find.text('Where does it hurt?'), findsOneWidget);
  });

  testWidgets('areas on both sides, pain level and notes reach the summary', (
    tester,
  ) async {
    useLargeScreen(tester);
    final backend = FakeBackend('pain');
    await pumpFlow(tester, painFlow, backend);

    // Step 1: nothing picked yet, so Continue is off.
    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(find.text('Nothing selected yet. Tap where it hurts.'), findsOne);
    expect(isEnabled(tester, 'Continue · 0 areas'), isFalse);

    // One area on the back, one on the front.
    await scrollAndTap(tester, find.text('Back'));
    await settle(tester);
    await _tapRegion(tester, 'back.lumbar_spine');
    await settle(tester);
    await scrollAndTap(tester, find.text('Front'));
    await settle(tester);
    await _tapRegion(tester, 'front.left_knee');
    await settle(tester);

    // Both show as removable chips, whichever side is open.
    expect(find.widgetWithText(InputChip, 'Lumbar Spine'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Left Knee'), findsOneWidget);

    // Tapping a selected area again removes it; tap it back.
    await _tapRegion(tester, 'front.left_knee');
    await settle(tester);
    expect(find.widgetWithText(InputChip, 'Left Knee'), findsNothing);
    await _tapRegion(tester, 'front.left_knee');
    await settle(tester);

    expect(isEnabled(tester, 'Continue · 2 areas'), isTrue);
    await scrollAndTap(tester, button('Continue · 2 areas'));
    await settle(tester);

    expect(backend.actions.last['name'], 'bodyAreasSelected');
    expect(backend.actions.last['context'], {
      'bodyAreas': ['Lumbar Spine', 'Left Knee'],
    });

    // Step 2: the areas, then the pain level scale, starting at 5.
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.text('Lumbar Spine, Left Knee'), findsOneWidget);
    expect(find.text('Pain level'), findsOneWidget);
    expect(find.text('Moderate'), findsOneWidget);
    final Finder seven = find.descendant(
      of: find.byType(SeverityScale),
      matching: find.text('7'),
    );
    await tester.ensureVisible(seven);
    await tester.tap(seven);
    await settle(tester);
    expect(find.text('Severe'), findsOneWidget);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    final context = backend.actions.last['context']! as Map<String, Object?>;
    expect(backend.actions.last['name'], 'painDetailsEntered');
    final level = context['painLevel']! as int;
    expect(level, 7);

    // Step 3: the shared notes screen, tagged with the pain level.
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(find.text('Pain $level/10'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Worse when I bend');
    await settle(tester);
    await scrollAndTap(tester, button('Save entry'));
    await settle(tester);

    expect(backend.actions.last['name'], 'savePainEntry');

    // Step 4: the shared summary.
    expect(find.text('Entry saved'), findsOneWidget);
    expect(find.text('Lumbar Spine, Left Knee'), findsOneWidget);
    expect(find.textContaining('$level/10 · '), findsOneWidget);
    expect(find.text('Worse when I bend'), findsOneWidget);
  });
}
