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

// Tests for the dialog that asks which city to search for care in.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/care_place.dart';
import 'package:vitalloop/widgets/flow/care_city_dialog.dart';

import '../../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  group('the city dialog', () {
    /// Opens the dialog and returns a function that reads what it closed
    /// with.
    Future<String? Function()> openDialog(WidgetTester tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showDialog<String>(
                context: context,
                builder: (_) =>
                    const CareCityDialog(initialCity: defaultCareCity),
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

    testWidgets('starts with the default city and returns the typed one', (
      tester,
    ) async {
      final String? Function() result = await openDialog(tester);
      expect(find.widgetWithText(TextField, 'California'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '  Pune ');
      await tester.tap(button('Find care'));
      await tester.pumpAndSettle();
      expect(result(), 'Pune');
      expect(find.byType(CareCityDialog), findsNothing);
    });

    testWidgets('an empty city can\'t be searched', (tester) async {
      await openDialog(tester);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(isEnabled(tester, 'Find care'), isFalse);
    });
  });
}
