// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

/// An interactive button that runs its `action` when pressed.
///
/// `variant` is "primary" (filled with the primary color), "borderless" (a
/// text button) or the default (filled with the surface color). While one of
/// its `checks` fails, the button is disabled.
final CatalogItem button = CatalogItem(
  name: 'Button',
  description: 'An interactive button that triggers an action when pressed.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Button'),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final ComponentProps props = itemContext.props;
    final ComponentNode<ComponentImplementation>? childNode = props.child(
      'child',
    );
    final Widget child = childNode == null
        ? const SizedBox.shrink()
        : itemContext.buildChild(childNode);

    final ThemeData theme = Theme.of(itemContext.buildContext);
    final ColorScheme colorScheme = theme.colorScheme;
    final String variant = stringOrNull(data['variant']) ?? '';
    final primary = variant == 'primary';
    final borderless = variant == 'borderless';

    final TextStyle? textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: primary ? colorScheme.onPrimary : colorScheme.onSurface,
    );

    final ButtonStyle style = switch (variant) {
      'primary' => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      'borderless' => TextButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
      ),
      _ => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    };

    // The button is enabled only while all of its checks pass.
    final NodeAction? action = props.action('action');
    final VoidCallback? onPressed = props.isValid
        ? () {
            if (action != null) unawaited(action());
          }
        : null;

    return borderless
        ? TextButton(onPressed: onPressed, child: child)
        : ElevatedButton(
            style: style.copyWith(textStyle: WidgetStatePropertyAll(textStyle)),
            onPressed: onPressed,
            child: child,
          );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "Button",
          "child": "text",
          "action": {
            "event": {
              "name": "button_pressed"
            }
          }
        },
        {
          "id": "text",
          "component": "Text",
          "text": "Hello World"
        }
      ]
    ''',
  ],
);
