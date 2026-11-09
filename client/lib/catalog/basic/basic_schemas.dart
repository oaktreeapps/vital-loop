// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../shared/catalog_item.dart';

/// The A2UI v1.0 basic catalog, the source of the basic components' schemas.
final CatalogApi _basicCatalog = BasicCatalog.v1_0();

/// The shared definitions the basic schemas point at (`#/$defs/...`), which
/// a catalog using [basicSchema] must carry.
Map<String, Object?> get basicSchemaDefinitions => _basicCatalog.definitions;

/// The A2UI v1.0 basic catalog's schema of the component [name], as a copy
/// that [patch] may change: it gets the schema's `properties` and the object
/// that holds them (with its `required` list).
///
/// The app's basic components keep the properties they had with genui (e.g.
/// Text's heading variants), so their schemas add those to the v1.0 ones.
Schema basicSchema(
  String name, [
  void Function(JsonMap properties, JsonMap holder)? patch,
]) {
  final JsonMap schema =
      (jsonDecode(jsonEncode(_basicCatalog.components[name]!.schema.value))
              as Map)
          .cast<String, Object?>();
  // The properties are at the top, or in an `allOf` branch next to Checkable.
  final holder = schema['properties'] is Map
      ? schema
      : ((schema['allOf']! as List)
                .whereType<Map<Object?, Object?>>()
                .firstWhere((branch) => branch['properties'] is Map))
            as JsonMap;
  patch?.call(holder['properties']! as JsonMap, holder);
  return Schema.fromMap(schema);
}
