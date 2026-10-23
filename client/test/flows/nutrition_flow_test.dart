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

// Widget tests for the nutrition flow, step by step from the meal type to the
// summary.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/flows/nutrition_flow.dart';

import '../support/fake_backend.dart';
import '../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  testWidgets('the JSON screens drive the whole nutrition flow', (
    tester,
  ) async {
    useLargeScreen(tester);
    await pumpFlow(tester, nutritionFlow, FakeBackend('nutrition'));

    // Step 1: tapping a meal tile goes straight to the next step.
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.text('Which meal are you logging?'), findsOneWidget);
    await scrollAndTap(tester, find.text('Lunch'));
    await settle(tester);

    // Step 2: earlier answer in the title; Continue needs at least one food.
    expect(find.text('What did you have for lunch?'), findsOneWidget);
    expect(isEnabled(tester, 'Continue · 0 items'), isFalse);
    await scrollAndTap(tester, find.text('Rice'));
    await tester.enterText(find.byType(TextField), 'Dal, Roti');
    await tester.pump();
    expect(isEnabled(tester, 'Continue · 1 item'), isTrue);
    await scrollAndTap(tester, button('Continue · 1 item'));
    await settle(tester);

    // Step 3: one slider card per food, built from the data model.
    expect(find.text('How much did you have?'), findsOneWidget);
    expect(find.text('3 foods'), findsOneWidget);
    for (final food in ['Rice', 'Dal', 'Roti']) {
      expect(find.text(food), findsOneWidget);
    }
    expect(find.byType(Slider), findsNWidgets(3));
    final Finder riceSlider = find.byType(Slider).first;
    await tester.ensureVisible(riceSlider);
    await tester.pump();
    final Rect riceBox = tester.getRect(riceSlider);
    await tester.tapAt(Offset(riceBox.right - 12, riceBox.center.dy));
    await settle(tester);
    await scrollAndTap(tester, button('Continue'));
    await settle(tester);

    // Step 4: day and time preset from the data model.
    expect(find.text('When did you have your lunch?'), findsOneWidget);
    expect(find.text('Typical lunch time · 12 – 3 pm'), findsOneWidget);
    await scrollAndTap(tester, button('Continue · Today, 1:00 PM'));
    await settle(tester);

    // Step 5: optional notes; the Save label follows what was typed.
    expect(find.text('Step 5 of 5'), findsOneWidget);
    expect(find.text('Anything else to note?'), findsOneWidget);
    expect(find.text('Today, 1:00 PM'), findsOneWidget);
    expect(find.text('0 / 280'), findsOneWidget);
    expect(isEnabled(tester, 'Save without notes'), isTrue);
    await tester.enterText(find.byType(TextField), 'Home cooked');
    await settle(tester);
    expect(find.text('11 / 280'), findsOneWidget);
    // Over 280 characters, Save is disabled.
    await tester.enterText(find.byType(TextField), 'x' * 281);
    await settle(tester);
    expect(isEnabled(tester, 'Save entry'), isFalse);
    await tester.enterText(find.byType(TextField), 'Home cooked');
    await settle(tester);
    await scrollAndTap(tester, button('Save entry'));
    await settle(tester);

    // Summary, filled from every earlier action.
    expect(find.text('Entry saved'), findsOneWidget);
    expect(find.text('Lunch · Today, 1:00 PM'), findsOneWidget);
    expect(
      find.text('Rice – 10, Dal – 1 serving, Roti – 1 serving'),
      findsOneWidget,
    );
    expect(find.text('Home cooked'), findsOneWidget);

    // The summary leads back to the dashboard instead of another meal.
    expect(button('Go to dashboard'), findsOneWidget);
    expect(find.text('Log another meal'), findsNothing);
  });
}
