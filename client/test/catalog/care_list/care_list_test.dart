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

// Tests for the CareList: a card per place, the empty text, touch sizes,
// the header, and long names on a small phone.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/care_list/widgets/care_list_view.dart';
import 'package:vitalloop/catalog/shared/widgets/care_place_card.dart';
import 'package:vitalloop/models/care_place.dart';

import '../../support/care_places.dart';
import '../../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  group('the list', () {
    testWidgets('a card per place, with Call only when there is a phone', (
      tester,
    ) async {
      final picked = <String>[];
      await pumpInPage(
        tester,
        CareListView(
          places: [
            CarePlace.fromJson(
              placeJson('a', {
                'phone': '+1 916-555-0100',
                'rating': 4.6,
                'ratingCount': 230,
                'reason': 'A hospital nearby.',
              }),
            )!,
            testPlace('b'),
          ],
          selectedId: 'b',
          onSelect: picked.add,
        ),
      );

      expect(find.byType(CarePlaceCard), findsNWidgets(2));
      expect(find.text('A hospital nearby.'), findsOneWidget);
      expect(find.text('4.6 (230)', findRichText: true), findsOneWidget);
      expect(find.byTooltip('Call'), findsOneWidget);
      expect(find.text('Directions'), findsNWidgets(2));
      expect(find.byTooltip('Website'), findsNothing);

      final List<CarePlaceCard> cards = tester
          .widgetList<CarePlaceCard>(find.byType(CarePlaceCard))
          .toList();
      expect([for (final c in cards) c.selected], [false, true]);

      await tester.tap(find.text('Place a'));
      expect(picked, ['a']);
    });

    testWidgets('no places: the empty text', (tester) async {
      await pumpInPage(
        tester,
        CareListView(
          places: const [],
          onSelect: (_) {},
          emptyText: 'Nothing near Sacramento.',
        ),
      );
      expect(find.text('Nothing near Sacramento.'), findsOneWidget);
      expect(find.byType(CarePlaceCard), findsNothing);
    });

    testWidgets('the buttons are at least 44 big to touch', (tester) async {
      await pumpInPage(
        tester,
        CareListView(
          places: [
            CarePlace.fromJson(
              placeJson('a', {
                'phone': '+1 916-555-0100',
                'website': 'https://example.com',
              }),
            )!,
          ],
          onSelect: (_) {},
        ),
      );
      final Size directions = tester.getSize(
        find.ancestor(
          of: find.text('Directions'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(directions.height, greaterThanOrEqualTo(44));
      for (final tooltip in ['Call', 'Website']) {
        final Size size = tester.getSize(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        );
        expect(size.width, greaterThanOrEqualTo(44), reason: tooltip);
        expect(size.height, greaterThanOrEqualTo(44), reason: tooltip);
      }
    });

    testWidgets('the header shows the title in capitals and the city', (
      tester,
    ) async {
      await pumpInPage(
        tester,
        CareListView(
          places: [testPlace('a')],
          onSelect: (_) {},
          title: 'Places nearby',
          city: 'Navsari',
        ),
      );
      expect(find.text('PLACES NEARBY'), findsOneWidget);
      expect(find.text('Navsari'), findsOneWidget);
      expect(find.byIcon(Icons.near_me_outlined), findsOneWidget);
    });

    testWidgets('long names and chips fit a 360 wide phone', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpInPage(
        tester,
        CareListView(
          places: [
            CarePlace.fromJson(
              placeJson('a', {
                'name': 'Advance Orthopaedic and Trauma Hospital of Navsari',
                'kind': 'Orthopedic hospital and trauma centre',
                'rating': 4.9,
                'ratingCount': 15700,
                'phone': '+91 99999 99999',
                'website': 'https://example.com',
                'reason': 'Orthopedic hospital nearby, for the acute pain.',
                'address': 'Lunsikui Rd, Navsari, Gujarat 396445, India',
              }),
            )!,
          ],
          onSelect: (_) {},
          title: 'Places nearby',
          city: 'Navsari',
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('no title: no header', (tester) async {
      await pumpInPage(
        tester,
        CareListView(places: [testPlace('a')], onSelect: (_) {}),
      );
      expect(find.byIcon(Icons.near_me_outlined), findsNothing);
    });
  });
}
