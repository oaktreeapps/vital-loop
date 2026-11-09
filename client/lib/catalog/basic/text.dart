// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

/// The Text component's variants: the v1.0 basic catalog's `body` and
/// `caption`, plus the headings `h1`–`h5` the app's screens use.
const List<String> textVariants = [
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'caption',
  'body',
];

/// A block of styled text; simple Markdown is rendered.
///
/// `variant` picks the base style from the theme (see
/// `core/theme/surface_theme.dart`): `h1`–`h5`, `caption` or `body` (the
/// default). Headings get some space above and below.
final CatalogItem text = CatalogItem(
  name: 'Text',
  description: 'A block of styled text.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Text', (properties, _) {
    (properties['variant']! as JsonMap)['enum'] = textVariants;
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['text'],
      builder: (context, value) {
        final TextTheme textTheme = Theme.of(context).textTheme;
        final String variant = stringOrNull(data['variant']) ?? 'body';
        final TextStyle? baseStyle = switch (variant) {
          'h1' => textTheme.headlineLarge,
          'h2' => textTheme.headlineMedium,
          'h3' => textTheme.headlineSmall,
          'h4' => textTheme.titleLarge,
          'h5' => textTheme.titleMedium,
          'caption' => textTheme.bodySmall,
          _ => DefaultTextStyle.of(context).style,
        };
        final double verticalPadding = switch (variant) {
          'h1' => 20.0,
          'h2' => 16.0,
          'h3' => 12.0,
          'h4' => 8.0,
          'h5' => 4.0,
          _ => 0.0,
        };

        return Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: MarkdownBody(
            data: value ?? '',
            styleSheet: MarkdownStyleSheet.fromTheme(
              Theme.of(context),
            ).copyWith(p: baseStyle),
          ),
        );
      },
    );
  },
  exampleData: [
    () => '''
      [
        {"id": "root", "component": "Text", "text": "Hello World"}
      ]
    ''',
  ],
);
