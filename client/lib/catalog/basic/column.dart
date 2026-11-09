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

/// A layout component that arranges its children vertically, 8 apart.
final CatalogItem column = CatalogItem(
  name: 'Column',
  description: 'A layout widget that arranges its children vertically.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Column'),
  widgetBuilder: (itemContext) =>
      buildFlex(itemContext, direction: Axis.vertical, spacing: 8),
  exampleData: [
    () => '''
      [
        {"id": "root", "component": "Column", "children": ["advice_text", "advice_options", "submit_button"]},
        {"id": "advice_text", "component": "Text", "text": "What kind of advice are you looking for?"},
        {"id": "advice_options", "component": "Text", "text": "Some advice options."},
        {"id": "submit_button", "component": "Button", "child": "submit_button_text", "action": {"event": {"name": "submit"}}},
        {"id": "submit_button_text", "component": "Text", "text": "Submit"}
      ]
    ''',
  ],
);
