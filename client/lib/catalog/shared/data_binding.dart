// Copyright 2026 Oaktreeapps
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

// Helpers for the custom catalog components: reading their optional JSON
// properties, and binding a number to the surface's data model.

/// The data-model path a value property binds to: its `{"path": ...}`, or a
/// path of this component's own when the JSON gave a literal number.
///
/// [ref] is the property's JSON value and [key] names the property, so a
/// component with two values (like blood pressure) gets two different paths,
/// e.g. "/bp_systolic" and "/bp_diastolic".
String bindingPath(CatalogItemContext itemContext, Object? ref, String key) =>
    ref is Map && ref['path'] is String
    ? ref['path'] as String
    : '/${itemContext.id}_$key';

/// [value] if it is a number, else `null`. Reads optional number properties
/// such as `min` or `step` from component JSON.
num? numberOrNull(Object? value) => value is num ? value : null;

/// [value] if it is a string, else `null`. Reads optional text properties
/// such as `label` from component JSON, which may hold anything.
String? stringOrNull(Object? value) => value is String ? value : null;

/// Reads the number at [path] and rebuilds when it changes. Writes [fallback]
/// to the data model if it has no value yet, so the step's Button always
/// sends a reading.
Widget bindNumber(
  CatalogItemContext itemContext,
  String path,
  num fallback,
  Widget Function(num value, ValueChanged<num> update) builder,
) {
  // Writes a new value back to the data model at [path].
  void update(num value) =>
      itemContext.dataContext.update(DataPath(path), value);
  return BoundNumber(
    dataContext: itemContext.dataContext,
    value: {'path': path},
    builder: (context, value) {
      if (value == null) {
        // Not allowed to change the data model during build, so write the
        // fallback right after this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) => update(fallback));
      }
      return builder(value ?? fallback, update);
    },
  );
}
