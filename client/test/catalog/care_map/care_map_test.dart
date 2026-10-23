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

// Tests for the CareMap: one pin per place, the camera, the OpenStreetMap
// map and its fallback, and the component's schema.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:latlong2/latlong.dart';
import 'package:vitalloop/catalog/care_map/care_map.dart';
import 'package:vitalloop/catalog/care_map/widgets/care_map_fallback.dart';
import 'package:vitalloop/catalog/care_map/widgets/care_map_markers.dart';
import 'package:vitalloop/catalog/care_map/widgets/care_map_pin.dart';
import 'package:vitalloop/catalog/care_map/widgets/care_map_view.dart';
import 'package:vitalloop/models/care_place.dart';

import '../../support/care_places.dart';
import '../../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  group('the map', () {
    test('one pin per place; the picked one is drawn last, in red', () {
      final picked = <String>[];
      final List<Marker> markers = carePlaceMarkers(
        [testPlace('a'), testPlace('b'), testPlace('c')],
        selectedId: 'b',
        onSelect: picked.add,
      );
      expect(markers.map((m) => m.key), [
        const ValueKey('a'),
        const ValueKey('c'),
        const ValueKey('b'),
      ]);
      final List<CareMapPin> pins = [
        for (final m in markers) m.child as CareMapPin,
      ];
      expect(pins.map((pin) => pin.selected), [false, false, true]);
      expect(pins.first.name, 'Place a');
      expect(markers.first.point, const LatLng(38.5, -121.5));

      pins.first.onTap();
      expect(picked, ['a']);
    });

    test(
      'the camera fits every place, or shows one, the city or the world',
      () {
        final List<CarePlace> two = [
          testPlace('a', lat: 38.4, lng: -121.6),
          testPlace('b', lat: 38.7, lng: -121.3),
        ];
        final fit = cameraFitFor(two)! as FitBounds;
        expect(fit.bounds.southWest, const LatLng(38.4, -121.6));
        expect(fit.bounds.northEast, const LatLng(38.7, -121.3));
        expect(cameraFitFor([two.first]), isNull);

        expect(cameraFor([two.first], null).zoom, placeZoom);
        expect(cameraFor([], const GeoPoint(38, -121)), (
          center: const LatLng(38, -121),
          zoom: cityZoom,
        ));
        expect(cameraFor([], null).zoom, worldZoom);
      },
    );

    testWidgets('an OpenStreetMap map, credited, with the pins', (
      tester,
    ) async {
      await pumpInPage(
        tester,
        CareMapView(
          places: [testPlace('a'), testPlace('b')],
          selectedId: 'a',
          onSelect: (_) {},
        ),
      );
      expect(find.byType(FlutterMap), findsOneWidget);
      final TileLayer tiles = tester.widget(find.byType(TileLayer));
      expect(tiles.urlTemplate, openStreetMapTiles);
      expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
      expect(find.byType(CareMapPin), findsNWidgets(2));
      // The picked place's name shows above its pin.
      expect(find.text('Place a'), findsOneWidget);
      expect(find.byType(CareMapFallback), findsNothing);
    });

    testWidgets('no places: a link to Google Maps, not an empty map', (
      tester,
    ) async {
      await pumpInPage(
        tester,
        CareMapView(places: const [], city: 'New York', onSelect: (_) {}),
      );
      expect(find.byType(FlutterMap), findsNothing);
      expect(find.text('No places to show on the map.'), findsOneWidget);
      expect(find.text('Open in Google Maps'), findsOneWidget);
      final CareMapFallback fallback = tester.widget(
        find.byType(CareMapFallback),
      );
      expect(fallback.searchUrl.queryParameters['query'], 'New York');
    });
  });

  group('the map component', () {
    /// The CareMap component in the server's nearby-care screen.
    Map<String, Object?> templateMap() {
      final messages =
          jsonDecode(
                File(
                  '$serverFlowsDir/daily_summary/02_nearby_care.json',
                ).readAsStringSync(),
              )
              as List<Object?>;
      for (final message in messages) {
        final Object? update = (message! as Map)['updateComponents'];
        if (update is! Map) continue;
        for (final Object? component in update['components'] as List) {
          final Map<String, Object?> map = (component! as Map)
              .cast<String, Object?>();
          if (map['component'] == 'CareMap') return map;
        }
      }
      throw StateError('No CareMap in the template');
    }

    test("the template's bound center passes CareMap's schema", () async {
      // The template binds the center: {"path": "/center"}. genui's
      // propertyReference rejected that ("matched 2" of its one-of).
      final Object? center = templateMap()['center'];
      expect(center, {'path': '/center'});
      final Schema schema = careMap.dataSchema.properties!['center']!;
      expect(await schema.validate(center), isEmpty);
    });

    test('a center is a point or a binding, and nothing else', () async {
      Future<bool> valid(Object? center) async =>
          (await centerSchema.validate(center)).isEmpty;
      expect(await valid({'lat': 40.7, 'lng': -74.0}), isTrue);
      expect(await valid({'path': '/center'}), isTrue);
      expect(await valid({'lat': 40.7}), isFalse);
      expect(await valid('New York'), isFalse);
    });
  });
}
