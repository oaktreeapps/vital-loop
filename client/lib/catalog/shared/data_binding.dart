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

import 'package:a2ui_core/a2ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'catalog_item.dart';

// Helpers for the catalog components: reading their optional JSON
// properties, and binding a value to the surface's data model.

/// The data-model path a value property binds to: its `{"@path": ...}`, or a
/// path of this component's own when the JSON gave a literal.
///
/// [ref] is the property's JSON value and [key] names the property, so a
/// component with two values (like blood pressure) gets two different paths,
/// e.g. "/bp_systolic" and "/bp_diastolic".
String bindingPath(CatalogItemContext itemContext, Object? ref, String key) =>
    ref is Map && ref['@path'] is String
    ? ref['@path'] as String
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
  void update(num value) => itemContext.dataContext.set(path, value);
  return BoundNumber(
    dataContext: itemContext.dataContext,
    value: {'@path': path},
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

/// Builds [builder] with a component property's current value and rebuilds
/// it when the value changes.
///
/// [value] is the property as the JSON gave it: a literal, a data-model
/// binding (`{"@path": ...}`) or a function call (`{"@call": ...}`), read
/// from [dataContext]. Subclasses say how the raw value becomes a [T].
abstract class BoundValue<T> extends StatefulWidget {
  /// Binds [value] in [dataContext] and shows it with [builder].
  const BoundValue({
    super.key,
    required this.dataContext,
    required this.value,
    required this.builder,
  });

  /// Where bindings and calls in [value] are resolved.
  final DataContext dataContext;

  /// The property's JSON: a literal, a binding or a function call.
  final Object? value;

  /// Builds the widget for the current value; `null` when there is none.
  final Widget Function(BuildContext context, T? value) builder;

  /// Turns the resolved [raw] value into a [T], or `null` if it isn't one.
  T? convert(Object? raw);

  @override
  State<BoundValue<T>> createState() => _BoundValueState<T>();
}

class _BoundValueState<T> extends State<BoundValue<T>> {
  /// Stops listening to the bound value.
  void Function()? _unsubscribe;

  /// The value the binding currently resolves to.
  Object? _raw;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(BoundValue<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.dataContext, oldWidget.dataContext) ||
        !_sameJson(widget.value, oldWidget.value)) {
      _unsubscribe?.call();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    super.dispose();
  }

  /// Resolves the value now and listens for its later changes.
  void _subscribe() {
    final ReadonlySignal<Object?> signal = widget.dataContext.resolveSignal(
      widget.value,
    );
    var primed = false;
    // subscribe() calls back right away with the current value.
    _unsubscribe = signal.subscribe((Object? value) {
      if (!primed) {
        _raw = value;
        return;
      }
      _onChanged(value);
    });
    primed = true;
  }

  /// Rebuilds with [value]; after the frame when one is being built.
  void _onChanged(Object? value) {
    if (!mounted) return;
    final SchedulerBinding scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      _raw = value;
      scheduler.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() => _raw = value);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.convert(_raw));
}

/// Whether two JSON values are equal, comparing lists and maps by content.
bool _sameJson(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_sameJson(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final MapEntry<Object?, Object?> entry in a.entries) {
      if (!b.containsKey(entry.key) || !_sameJson(entry.value, b[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}

/// A property shown as text: any value becomes its string.
class BoundString extends BoundValue<String> {
  /// Binds a text property.
  const BoundString({
    super.key,
    required super.dataContext,
    required super.value,
    required super.builder,
  });

  @override
  String? convert(Object? raw) => raw?.toString();
}

/// A yes/no property: a bool, "true"/"false" text, or a number (0 is no).
class BoundBool extends BoundValue<bool> {
  /// Binds a yes/no property.
  const BoundBool({
    super.key,
    required super.dataContext,
    required super.value,
    required super.builder,
  });

  @override
  bool? convert(Object? raw) {
    if (raw is bool) return raw;
    if (raw is String) {
      if (raw.toLowerCase() == 'true') return true;
      if (raw.toLowerCase() == 'false') return false;
    }
    if (raw is num) return raw != 0;
    return null;
  }
}

/// A number property: a number, or text that parses as one.
class BoundNumber extends BoundValue<num> {
  /// Binds a number property.
  const BoundNumber({
    super.key,
    required super.dataContext,
    required super.value,
    required super.builder,
  });

  @override
  num? convert(Object? raw) {
    if (raw is num) return raw;
    if (raw is String) return num.tryParse(raw);
    return null;
  }
}

/// A list property.
class BoundList extends BoundValue<List<Object?>> {
  /// Binds a list property.
  const BoundList({
    super.key,
    required super.dataContext,
    required super.value,
    required super.builder,
  });

  @override
  List<Object?>? convert(Object? raw) =>
      raw is List ? raw.cast<Object?>() : null;
}

/// A property of any JSON type, as it is.
class BoundObject extends BoundValue<Object> {
  /// Binds a property of any type.
  const BoundObject({
    super.key,
    required super.dataContext,
    required super.value,
    required super.builder,
  });

  @override
  Object? convert(Object? raw) => raw;
}
