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

// Helpers for the care nearby tests: a place's JSON as the server sends it,
// a place made from it, and a scrolling page to show a widget in.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/care_place.dart';

/// A place's JSON as the server sends it; [fields] override its values.
Map<String, Object?> placeJson(
  String id, [
  Map<String, Object?> fields = const {},
]) => {
  'id': id,
  'name': 'Place $id',
  'kind': 'Hospital',
  'type': 'hospital',
  'address': '$id Street',
  'lat': 38.5,
  'lng': -121.5,
  ...fields,
};

/// The place [id], at [lat], [lng].
CarePlace testPlace(String id, {double lat = 38.5, double lng = -121.5}) =>
    CarePlace.fromJson(placeJson(id, {'lat': lat, 'lng': lng}))!;

/// Shows [child] in a scrolling page, like a flow's surface.
Future<void> pumpInPage(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  ),
);
