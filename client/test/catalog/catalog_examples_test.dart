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

// Checks every custom component's example A2UI JSON: it passes the
// component's own schema, so the catalog previews and the instructions
// Gemini gets show valid JSON.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart' show CatalogItem;
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:vitalloop/catalog/care_map/care_map.dart';
import 'package:vitalloop/screens/catalog_screen.dart';

void main() {
  for (final CatalogItem item in customCatalogItems) {
    test('${item.name}: the example passes its schema', () async {
      final List<Map<String, Object?>> components = [
        for (final Object? c in jsonDecode(item.exampleData.first()) as List)
          (c! as Map).cast<String, Object?>(),
      ];
      final Map<String, Object?> component = components.firstWhere(
        (c) => c['component'] == item.name,
      );
      final List<ValidationError> errors = await item.dataSchema.validate(
        component,
      );
      expect(errors, isEmpty, reason: '$errors');
    });
  }

  test('a component missing a required property fails its schema', () async {
    final List<ValidationError> errors = await careMap.dataSchema.validate({
      'id': 'root',
      'component': 'CareMap',
      'city': 'Sacramento',
    });
    expect(errors, isNotEmpty);
  });
}
