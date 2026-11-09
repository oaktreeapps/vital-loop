// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';

import '../shared/catalog_item.dart';
import 'basic_schemas.dart';

/// A scrollable list of child components, vertical (the default) or
/// horizontal.
final CatalogItem list = CatalogItem(
  name: 'List',
  description: 'A scrollable list of child widgets.',
  isImplicitlyFlexible: true,
  schemaIsComplete: true,
  dataSchema: basicSchema('List'),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final Axis direction = data['direction'] == 'horizontal'
        ? Axis.horizontal
        : Axis.vertical;
    final CrossAxisAlignment crossAxisAlignment = switch (data['align']) {
      'start' => CrossAxisAlignment.start,
      'center' => CrossAxisAlignment.center,
      'end' => CrossAxisAlignment.end,
      'stretch' => CrossAxisAlignment.stretch,
      _ => CrossAxisAlignment.center,
    };
    return SingleChildScrollView(
      scrollDirection: direction,
      child: Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (final ComponentNode<ComponentImplementation> child
              in itemContext.props.children('children'))
            itemContext.buildChild(child),
        ],
      ),
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "List",
          "children": [
            "text1",
            "text2"
          ]
        },
        {
          "id": "text1",
          "component": "Text",
          "text": "First"
        },
        {
          "id": "text2",
          "component": "Text",
          "text": "Second"
        }
      ]
    ''',
  ],
);
