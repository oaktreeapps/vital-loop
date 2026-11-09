// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:flutter/material.dart';

import '../shared/catalog_item.dart';
import 'basic_schemas.dart';

/// A thin horizontal or vertical line that separates content.
final CatalogItem divider = CatalogItem(
  name: 'Divider',
  description: 'A thin horizontal or vertical line used to separate content.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Divider'),
  widgetBuilder: (itemContext) => itemContext.data['axis'] == 'vertical'
      ? const VerticalDivider()
      : const Divider(),
  exampleData: [
    () => '''
      [
        {"id": "root", "component": "Divider"}
      ]
    ''',
  ],
);
