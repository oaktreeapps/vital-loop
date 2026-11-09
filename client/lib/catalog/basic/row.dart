// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:flutter/widgets.dart';

import '../shared/catalog_item.dart';
import 'basic_schemas.dart';
import 'flex.dart';

/// A layout component that arranges its children horizontally, 16 apart.
final CatalogItem row = CatalogItem(
  name: 'Row',
  description: 'A layout widget that arranges its children horizontally.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Row'),
  widgetBuilder: (itemContext) =>
      buildFlex(itemContext, direction: Axis.horizontal, spacing: 16),
  exampleData: [
    () => '''
      [
        {"id": "root", "component": "Row", "children": ["text1", "text2"]},
        {"id": "text1", "component": "Text", "text": "First"},
        {"id": "text2", "component": "Text", "text": "Second"}
      ]
    ''',
  ],
);
