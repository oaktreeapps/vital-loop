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

/// Lets the user pick one option (`variant` "mutuallyExclusive") or several
/// ("multipleSelection") from `options`, shown as a list of radio buttons or
/// check boxes, or as chips (`displayStyle` "chips").
///
/// The picked values are written to the bound `value` path as a list of
/// strings; without a binding they are kept under this component's own path.
final CatalogItem choicePicker = CatalogItem(
  name: 'ChoicePicker',
  description:
      'A component that allows selecting one or more options from a list.',
  isImplicitlyFlexible: true,
  schemaIsComplete: true,
  dataSchema: basicSchema('ChoicePicker', (properties, _) {
    // The options may also be a list in the data model.
    properties['options'] = {
      'oneOf': [
        properties['options'],
        {r'$ref': r'common_types.json#/$defs/DataBinding'},
      ],
    };
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final Object? valueRef = data['value'];
    final path = valueRef is Map && valueRef['@path'] is String
        ? valueRef['@path'] as String
        : '${itemContext.id}.value';
    final bool isError = !itemContext.props.isValid;

    return BoundList(
      dataContext: itemContext.dataContext,
      value: data['options'],
      builder: (context, options) {
        final Widget pickerWidget = _ChoicePicker(
          label: data['label'],
          options: options,
          valueRef: valueRef,
          path: path,
          itemContext: itemContext,
          isMutuallyExclusive: data['variant'] == 'mutuallyExclusive',
          isChips: data['displayStyle'] == 'chips',
          filterable: data['filterable'] == true,
        );

        if (!isError) return pickerWidget;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pickerWidget,
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Text(
                'Invalid selection',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "Column",
          "children": ["heading1", "radio", "heading2", "check"]
        },
        { "id": "heading1", "component": "Text", "text": "Mutually Exclusive", "variant": "h4" },
        { "id": "radio", "component": "ChoicePicker", "variant": "mutuallyExclusive", "label": "Choose one", "value": ["A"], "options": [ { "label": "A", "value": "A" }, { "label": "B", "value": "B" } ] },
        { "id": "heading2", "component": "Text", "text": "Multiple Selection", "variant": "h4" },
        { "id": "check", "component": "ChoicePicker", "variant": "multipleSelection", "label": "Choose many", "value": { "@path": "/multi" }, "options": [ { "label": "X", "value": "X" }, { "label": "Y", "value": "Y" } ] }
      ]
    ''',
  ],
);

class _ChoicePicker extends StatefulWidget {
  const _ChoicePicker({
    required this.label,
    required this.options,
    required this.valueRef,
    required this.path,
    required this.itemContext,
    required this.isMutuallyExclusive,
    required this.isChips,
    required this.filterable,
  });

  final Object? label;
  final List<Object?>? options;
  final Object? valueRef;
  final String path;
  final CatalogItemContext itemContext;
  final bool isMutuallyExclusive;
  final bool isChips;
  final bool filterable;

  @override
  State<_ChoicePicker> createState() => _ChoicePickerState();
}

class _ChoicePickerState extends State<_ChoicePicker> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
            child: BoundString(
              dataContext: widget.itemContext.dataContext,
              value: widget.label,
              builder: (context, label) {
                if (label == null || label.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
          ),
        if (widget.filterable)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Filter options',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
        BoundObject(
          dataContext: widget.itemContext.dataContext,
          value: {'@path': widget.path},
          builder: (context, currentSelections) {
            var effectiveSelections = currentSelections;
            if (effectiveSelections == null) {
              if (widget.valueRef is List) {
                effectiveSelections = widget.valueRef;
              } else if (widget.valueRef is String) {
                effectiveSelections = [widget.valueRef];
              }
            } else if (effectiveSelections is! List) {
              effectiveSelections = [effectiveSelections];
            }

            final List<String> currentStrings =
                (effectiveSelections as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];

            if (widget.options == null) {
              return const SizedBox.shrink();
            }

            final List<Widget> optionWidgets = [];
            for (final Object? rawOption in widget.options!) {
              if (rawOption is! Map) continue;
              final optionValue = '${rawOption['value']}';
              optionWidgets.add(
                BoundString(
                  dataContext: widget.itemContext.dataContext,
                  value: rawOption['label'],
                  builder: (context, label) {
                    if (widget.filterable &&
                        _filter.isNotEmpty &&
                        label != null &&
                        !label.toLowerCase().contains(_filter.toLowerCase())) {
                      return const SizedBox.shrink();
                    }

                    if (widget.isChips) {
                      final bool selected = currentStrings.contains(
                        optionValue,
                      );
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FilterChip(
                          label: Text(label ?? ''),
                          selected: selected,
                          onSelected: (bool selected) {
                            _updateSelection(
                              selected,
                              optionValue,
                              currentStrings,
                            );
                          },
                        ),
                      );
                    }

                    if (widget.isMutuallyExclusive) {
                      final String? groupValue = currentStrings.isNotEmpty
                          ? currentStrings.first
                          : null;
                      return RadioListTile<String>(
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: Text(label ?? ''),
                        value: optionValue,
                        // ignore: deprecated_member_use
                        groupValue: groupValue,
                        // ignore: deprecated_member_use
                        onChanged: (newValue) {
                          if (newValue == null) return;
                          widget.itemContext.dataContext.set(widget.path, [
                            newValue,
                          ]);
                        },
                      );
                    } else {
                      return CheckboxListTile(
                        title: Text(label ?? ''),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: currentStrings.contains(optionValue),
                        onChanged: (newValue) {
                          _updateSelection(
                            newValue == true,
                            optionValue,
                            currentStrings,
                          );
                        },
                      );
                    }
                  },
                ),
              );
            }

            if (widget.isChips) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(children: optionWidgets),
              );
            }

            return Column(children: optionWidgets);
          },
        ),
      ],
    );
  }

  /// Writes the selection after [optionValue] was picked ([selected]) or
  /// unpicked. A mutually exclusive picker keeps only the picked option.
  void _updateSelection(
    bool selected,
    String optionValue,
    List<String> currentStrings,
  ) {
    if (widget.isMutuallyExclusive) {
      if (selected) {
        widget.itemContext.dataContext.set(widget.path, [optionValue]);
      }
    } else {
      final newSelections = List<String>.from(currentStrings);
      if (selected) {
        if (!newSelections.contains(optionValue)) {
          newSelections.add(optionValue);
        }
      } else {
        newSelections.remove(optionValue);
      }
      widget.itemContext.dataContext.set(widget.path, newSelections);
    }
  }
}
