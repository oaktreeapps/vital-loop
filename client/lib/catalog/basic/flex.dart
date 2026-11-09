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

/// Component types that get a share of a Row's or Column's free space even
/// without a `weight`: inputs that want all the width they can get.
const Set<String> implicitlyFlexibleTypes = {
  'CheckBox',
  'ChoicePicker',
  'DateTimeInput',
  'List',
  'TextField',
};

MainAxisAlignment _mainAxisAlignment(Object? justify) => switch (justify) {
  'start' => MainAxisAlignment.start,
  'center' => MainAxisAlignment.center,
  'end' => MainAxisAlignment.end,
  'spaceBetween' => MainAxisAlignment.spaceBetween,
  'spaceAround' => MainAxisAlignment.spaceAround,
  'spaceEvenly' => MainAxisAlignment.spaceEvenly,
  _ => MainAxisAlignment.start,
};

CrossAxisAlignment _crossAxisAlignment(Object? align) => switch (align) {
  'start' => CrossAxisAlignment.start,
  'center' => CrossAxisAlignment.center,
  'end' => CrossAxisAlignment.end,
  'stretch' => CrossAxisAlignment.stretch,
  _ => CrossAxisAlignment.start,
};

/// The `weight` the JSON gave [child], if it is a whole number.
int? _explicitWeight(ComponentNode<ComponentImplementation> child) =>
    switch (child.context?.componentModel.properties['weight']) {
      final int weight => weight,
      final double weight when weight == weight.roundToDouble() =>
        weight.round(),
      _ => null,
    };

/// [child]'s widget, in a [Flexible] when it has a `weight` or its type is
/// one of the [implicitlyFlexibleTypes].
Widget _weightedChild(
  CatalogItemContext itemContext,
  ComponentNode<ComponentImplementation> child,
) {
  final Widget widget = itemContext.buildChild(child);
  final int? explicitWeight = _explicitWeight(child);
  final int? weight =
      explicitWeight ??
      (implicitlyFlexibleTypes.contains(child.type) ? 1 : null);
  if (weight == null) return widget;
  return Flexible(
    flex: weight,
    fit: explicitWeight != null ? FlexFit.tight : FlexFit.loose,
    child: widget,
  );
}

/// Builds a Row ([direction] horizontal) or Column (vertical) from its
/// `children`, `justify` and `align`.
///
/// Children listed by id are [spacing] apart. Children built from a list
/// template (`{"componentId": ..., "path": ...}`, one per item of the list
/// in the data model) have no space between them, as with genui.
Widget buildFlex(
  CatalogItemContext itemContext, {
  required Axis direction,
  required double spacing,
}) {
  final JsonMap data = itemContext.data;
  final isTemplate = data['children'] is Map;
  return Flex(
    direction: direction,
    mainAxisAlignment: _mainAxisAlignment(data['justify']),
    crossAxisAlignment: _crossAxisAlignment(data['align']),
    mainAxisSize: MainAxisSize.min,
    spacing: isTemplate ? 0 : spacing,
    children: [
      for (final ComponentNode<ComponentImplementation> child
          in itemContext.props.children('children'))
        _weightedChild(itemContext, child),
    ],
  );
}
