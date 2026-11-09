// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:flutter/material.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

/// A check box with a label, for a yes/no value.
///
/// Ticking it writes `true` or `false` to the bound `value` path; without a
/// binding the value is kept under this component's own path.
final CatalogItem checkBox = CatalogItem(
  name: 'CheckBox',
  description: 'A selectable checkbox used for boolean toggles with a label.',
  isImplicitlyFlexible: true,
  schemaIsComplete: true,
  dataSchema: basicSchema('CheckBox'),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final Object? valueRef = data['value'];
    final path = valueRef is Map && valueRef['@path'] is String
        ? valueRef['@path'] as String
        : '${itemContext.id}.value';
    final bool isError = !itemContext.props.isValid;

    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['label'],
      builder: (context, label) => ListTileTheme.merge(
        child: BoundBool(
          dataContext: itemContext.dataContext,
          value: {'@path': path},
          builder: (context, value) => CheckboxListTile(
            title: Text(label ?? ''),
            value: value ?? false,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                itemContext.dataContext.set(path, newValue);
              }
            },
            subtitle: isError
                ? Text(
                    'Invalid value',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  )
                : null,
            isError: isError,
          ),
        ),
      ),
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "CheckBox",
          "label": "Check me",
          "value": {
            "@path": "/myValue"
          }
        }
      ]
    ''',
  ],
);
