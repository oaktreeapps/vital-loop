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

/// A visual container (card) around a single child.
final CatalogItem card = CatalogItem(
  name: 'Card',
  description: 'A visual container (card) that groups a single child widget.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Card'),
  widgetBuilder: (itemContext) {
    final ComponentNode<ComponentImplementation>? child = itemContext.props
        .child('child');
    return Card(
      color: Theme.of(itemContext.buildContext).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child == null
            ? const SizedBox.shrink()
            : itemContext.buildChild(child),
      ),
    );
  },
  exampleData: [
    () => '''
      [
        {"id": "root", "component": "Card", "child": "text"},
        {"id": "text", "component": "Text", "text": "This is a card."}
      ]
    ''',
  ],
);
