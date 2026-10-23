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

// Tests for reading care places from the screen's JSON: every value, the
// places left out, safe links, and the map's center.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/care_place.dart';

import '../support/care_places.dart';

void main() {
  group('places from the screen', () {
    test('a place is read with every value it has', () {
      final CarePlace place = CarePlace.fromJson(
        placeJson('a', {
          'rating': 4,
          'ratingCount': 12.0,
          'phone': '+1 (916) 555-0100',
          'website': 'https://example.com',
          'reason': '  For the knee pain you logged. ',
        }),
      )!;
      expect(place.name, 'Place a');
      expect(place.position, const GeoPoint(38.5, -121.5));
      expect(place.rating, 4.0);
      expect(place.ratingCount, 12);
      expect(place.phoneUrl, Uri(scheme: 'tel', path: '+19165550100'));
      expect(place.website, Uri.parse('https://example.com'));
      expect(place.reason, 'For the knee pain you logged.');
      expect(place.directionsUrl.queryParameters['destination_place_id'], 'a');
    });

    test('a place without an id, a name or a valid position is left out', () {
      expect(CarePlace.fromJson(placeJson('a', {'lat': '38.5'})), isNull);
      expect(CarePlace.fromJson(placeJson('a', {'lat': 120})), isNull);
      expect(CarePlace.fromJson(placeJson('a', {'name': ' '})), isNull);
      expect(CarePlace.fromJson(placeJson('', {})), isNull);
      expect(CarePlace.fromJson('a'), isNull);
    });

    test('only web links are kept, and wrong values are dropped', () {
      final CarePlace place = CarePlace.fromJson(
        placeJson('a', {
          'website': 'javascript:alert(1)',
          'mapsUrl': 'not a link',
          'rating': 'great',
          'phone': '',
        }),
      )!;
      expect(place.website, isNull);
      expect(place.mapsUrl, isNull);
      expect(place.rating, isNull);
      expect(place.phoneUrl, isNull);
    });

    test('a list keeps valid places in order, each once', () {
      final List<CarePlace> places = carePlacesFrom([
        placeJson('a'),
        {'id': 'broken'},
        placeJson('b'),
        placeJson('a'),
      ]);
      expect([for (final p in places) p.id], ['a', 'b']);
      expect(carePlacesFrom({'not': 'a list'}), isEmpty);
    });

    test('a center is a point, or nothing', () {
      expect(geoPointFrom({'lat': 1, 'lng': 2}), const GeoPoint(1, 2));
      expect(geoPointFrom({'lat': 1}), isNull);
      expect(geoPointFrom('here'), isNull);
    });
  });
}
