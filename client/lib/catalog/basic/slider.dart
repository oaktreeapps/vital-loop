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

/// A slider for picking a number from `min` (default 0) to `max` (default
/// 1), in steps of 1, with the current value next to it.
///
/// Moving it writes the number to the bound `value` path. Without a binding
/// the value is kept under this component's own path.
final CatalogItem slider = CatalogItem(
  name: 'Slider',
  description: 'A slider for selecting a value from a range.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Slider', (_, holder) {
    holder['required'] = ['component', 'value'];
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final Object? valueRef = data['value'];
    final path = valueRef is Map && valueRef['@path'] is String
        ? valueRef['@path'] as String
        : '${itemContext.id}.value';
    final double min = numberOrNull(data['min'])?.toDouble() ?? 0.0;
    final double max = numberOrNull(data['max'])?.toDouble() ?? 1.0;
    final bool isValid = itemContext.props.isValid;

    return BoundNumber(
      dataContext: itemContext.dataContext,
      value: {'@path': path},
      builder: (context, value) {
        // With nothing in the data model yet, fall back to a literal value.
        var effectiveValue = value;
        if (effectiveValue == null && valueRef is num) {
          effectiveValue = valueRef;
        }

        final Widget sliderWidget = Padding(
          padding: const EdgeInsetsDirectional.only(end: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Slider(
                  value: (effectiveValue ?? min).toDouble(),
                  min: min,
                  max: max,
                  divisions: (max - min).toInt(),
                  onChanged: (newValue) =>
                      itemContext.dataContext.set(path, newValue),
                ),
              ),
              Text(value?.toStringAsFixed(0) ?? min.toStringAsFixed(0)),
            ],
          ),
        );

        return BoundString(
          dataContext: itemContext.dataContext,
          value: data['label'],
          builder: (context, label) {
            final List<Widget> children = [
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              sliderWidget,
              if (!isValid)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(
                    'Invalid value',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ];
            if (children.length == 1) return children.first;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            );
          },
        );
      },
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "Slider",
          "min": 0,
          "max": 10,
          "value": {
            "@path": "/myValue"
          }
        }
      ]
    ''',
  ],
);
