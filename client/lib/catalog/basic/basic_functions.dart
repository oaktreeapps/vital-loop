// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:a2ui_core/a2ui_core.dart';
import 'package:intl/intl.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'format_string.dart';

/// A function whose behaviour is a closure over its resolved arguments.
class _Function extends FunctionImplementation {
  _Function({
    required super.name,
    required super.returnType,
    required super.description,
    required Map<String, Schema> arguments,
    required Object? Function(Map<String, dynamic> args) body,
  }) : _body = body,
       super(
         argumentSchema: Schema.object(
           properties: arguments,
           additionalProperties: true,
         ),
       );

  final Object? Function(Map<String, dynamic> args) _body;

  @override
  Object? execute(
    Map<String, dynamic> args,
    DataContext context, [
    CancellationSignal? cancellationSignal,
  ]) => _body(args);
}

/// `required`: whether `value` is there and not empty (text, list or map).
final FunctionImplementation _required = _Function(
  name: 'required',
  returnType: A2uiReturnType.boolean,
  description: 'Checks that the value is not null, undefined, or empty.',
  arguments: {'value': CommonSchemasV1.dynamicValue},
  body: (args) {
    if (!args.containsKey('value')) return false;
    final Object? value = args['value'];
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  },
);

/// `regex`: whether the text `value` has a match of `pattern`.
final FunctionImplementation _regex = _Function(
  name: 'regex',
  returnType: A2uiReturnType.boolean,
  description: 'Checks that the value matches a regular expression string.',
  arguments: {
    'value': CommonSchemasV1.dynamicString,
    'pattern': Schema.string(),
  },
  body: (args) {
    final Object? value = args['value'];
    final Object? pattern = args['pattern'];
    if (value is! String || pattern is! String) return false;
    return RegExp(pattern).hasMatch(value);
  },
);

/// `length`: the length of `value` (text, list or map; 0 otherwise). With
/// `min` or `max`, whether the length is within them instead.
final FunctionImplementation _length = _Function(
  name: 'length',
  returnType: A2uiReturnType.any,
  description:
      'Returns the length of a string, list or map. With min or max, checks '
      'the length against them instead.',
  arguments: {
    'value': CommonSchemasV1.dynamicValue,
    'min': Schema.integer(),
    'max': Schema.integer(),
  },
  body: (args) {
    final int length = switch (args['value']) {
      final String text => text.length,
      final List<Object?> list => list.length,
      final Map<Object?, Object?> map => map.length,
      _ => 0,
    };
    if (args.containsKey('min') || args.containsKey('max')) {
      final Object? min = args['min'];
      if (min is num && length < min) return false;
      final Object? max = args['max'];
      if (max is num && length > max) return false;
      return true;
    }
    return length;
  },
);

/// `formatDate`: the date-time `value` (ISO text, or milliseconds since
/// 1970) written with the `pattern`, e.g. "d MMM, h:mm a". The v1.0 basic
/// catalog's name for the pattern, `format`, works too.
final FunctionImplementation _formatDate = _Function(
  name: 'formatDate',
  returnType: A2uiReturnType.string,
  description: 'Formats a timestamp into a string using a pattern.',
  arguments: {
    'value': CommonSchemasV1.dynamicValue,
    'pattern': CommonSchemasV1.dynamicString,
    'format': CommonSchemasV1.dynamicString,
  },
  body: (args) {
    final Object? dateVal = args['value'];
    final Object? pattern = args['pattern'] ?? args['format'];

    DateTime? date;
    if (dateVal is String) {
      date = DateTime.tryParse(dateVal);
    } else if (dateVal is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateVal);
    }

    if (date == null || pattern is! String) return dateVal?.toString();

    try {
      return DateFormat(pattern).format(date);
    } on Object {
      return date.toString();
    }
  },
);

/// `formatNumber`: the number `value` with grouping (unless `useGrouping`
/// is false) and, if given, exactly `decimalPlaces` decimals.
final FunctionImplementation _formatNumber = _Function(
  name: 'formatNumber',
  returnType: A2uiReturnType.string,
  description:
      'Formats a number with the specified grouping and decimal precision.',
  arguments: {
    'value': CommonSchemasV1.dynamicNumber,
    'decimalPlaces': Schema.integer(),
    'useGrouping': Schema.boolean(),
  },
  body: (args) {
    final Object? number = args['value'];
    if (number is! num) return number?.toString() ?? '';

    final formatter = NumberFormat.decimalPattern();
    if (args['useGrouping'] == false) formatter.turnOffGrouping();
    final Object? decimalPlaces = args['decimalPlaces'];
    if (decimalPlaces is num) {
      formatter
        ..minimumFractionDigits = decimalPlaces.toInt()
        ..maximumFractionDigits = decimalPlaces.toInt();
    }
    return formatter.format(number);
  },
);

/// `pluralize`: the text for the plural category of the count `value`
/// (`zero`, `one`, `two`, `few`, `many`), else `other`.
final FunctionImplementation _pluralize = _Function(
  name: 'pluralize',
  returnType: A2uiReturnType.string,
  description:
      'Returns a localized string based on the Common Locale Data Repository '
      '(CLDR) plural category of the count (zero, one, two, few, many, '
      "other). Requires an 'other' fallback.",
  arguments: {
    'value': CommonSchemasV1.dynamicNumber,
    'zero': Schema.string(),
    'one': Schema.string(),
    'two': Schema.string(),
    'few': Schema.string(),
    'many': Schema.string(),
    'other': Schema.string(),
  },
  body: (args) {
    final Object? count = args['value'] ?? args['count'];
    if (count is! num) return '';
    String? text(String key) => args[key]?.toString();
    return Intl.pluralLogic(
      count,
      zero: text('zero'),
      one: text('one'),
      two: text('two'),
      few: text('few'),
      many: text('many'),
      other: text('other') ?? '',
    );
  },
);

/// The functions the JSON screens can call: the A2UI v1.0 basic catalog's,
/// with `formatString`, `formatDate`, `formatNumber`, `pluralize`, `length`,
/// `required` and `regex` behaving as they did with genui, which the app's
/// screens are written for.
List<FunctionImplementation> vitalLoopFunctions() {
  final Map<String, FunctionImplementation> functions = {
    ...BasicCatalog.v1_0().functions,
    for (final FunctionImplementation function in [
      _required,
      _regex,
      _length,
      _formatDate,
      _formatNumber,
      _pluralize,
    ])
      function.name: function,
  };
  // formatString calls the other functions (and itself) by name.
  functions['formatString'] = InterpolatedFormatString(() => functions);
  return functions.values.toList();
}
