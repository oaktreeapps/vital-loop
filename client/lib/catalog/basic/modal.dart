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

/// A button showing its `trigger` component that opens its `content`
/// component in a sheet sliding up from the bottom of the screen.
final CatalogItem modal = CatalogItem(
  name: 'Modal',
  description: 'A modal overlay that slides up from the bottom of the screen.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Modal'),
  widgetBuilder: (itemContext) {
    final ComponentNode<ComponentImplementation>? trigger = itemContext.props
        .child('trigger');
    final ComponentNode<ComponentImplementation>? content = itemContext.props
        .child('content');
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: itemContext.buildContext,
          builder: (context) => content == null
              ? const SizedBox.shrink()
              : itemContext.buildChild(content),
        );
      },
      child: trigger == null
          ? const SizedBox.shrink()
          : itemContext.buildChild(trigger),
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "Modal",
          "trigger": "trigger_text",
          "content": "modal_content"
        },
        {
          "id": "trigger_text",
          "component": "Text",
          "text": "Open Modal"
        },
        {
          "id": "modal_content",
          "component": "Text",
          "text": "This is a modal."
        }
      ]
    ''',
  ],
);
