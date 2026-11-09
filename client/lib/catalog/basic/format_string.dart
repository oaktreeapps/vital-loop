// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's formatString function, for
// A2UI v1.0 and a2ui_core.

import 'package:a2ui_core/a2ui_core.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:logging/logging.dart';

final Logger _log = Logger('formatString');

/// The `formatString` function: fills the `${...}` expressions in its
/// `value` text and returns the result.
///
/// An expression is a data-model path (`${/absolute/path}` or
/// `${relative/path}`) or a call of another catalog function with named
/// arguments (`${formatDate(value:${/when}, pattern:'h:mm a')}`). An
/// argument is a number, `true`, `false`, `null`, a path, a nested
/// `${...}`, or quoted text, in which `${...}` is filled too
/// (`'Step ${/step}'`). `\${` gives a literal `${`.
///
/// The result follows the data model: it is a signal that changes when a
/// value it read changes.
class InterpolatedFormatString extends FunctionImplementation {
  /// Creates the function. `functions` gives the catalog's functions by
  /// name, for the calls inside a template.
  InterpolatedFormatString(this._functions)
    : super(
        name: 'formatString',
        returnType: A2uiReturnType.string,
        description:
            r'Performs string interpolation of data model values and other '
            r'functions in the catalog functions list and returns the '
            r'resulting string. The value string can contain interpolated '
            r'expressions in the ${expression} format: JSON Pointer paths to '
            r'the data model (e.g. ${/absolute/path} or ${relative/path}) '
            r'and function calls with named arguments (e.g. '
            r"${formatDate(value:${/currentDate}, pattern:'MM-dd')}). To "
            r'include a literal ${ sequence, escape it as \${.',
        argumentSchema: Schema.object(additionalProperties: true),
      );

  final Map<String, FunctionImplementation> Function() _functions;

  @override
  Object? execute(
    Map<String, dynamic> args,
    DataContext context, [
    CancellationSignal? cancellationSignal,
  ]) {
    if (!args.containsKey('value')) return '';
    final String template = args['value']?.toString() ?? '';
    if (!template.contains(r'${')) return template;
    return computed(() {
      final evaluator = _Evaluator(context, _functions());
      return evaluator.interpolate(template, 1)?.toString() ?? '';
    });
  }
}

/// Evaluates the expressions of one template against a data context.
///
/// Every data-model value is read through a signal, so a `computed` around
/// the evaluation runs again when one of them changes.
class _Evaluator {
  _Evaluator(this.context, this.functions);

  final DataContext context;
  final Map<String, FunctionImplementation> functions;

  static const int _maxDepth = 100;

  static final RegExp _call = RegExp(r'^([a-zA-Z0-9_]+)\s*\(');

  /// Fills the `${...}` expressions of [input].
  ///
  /// Text that is one expression and nothing else gives the expression's
  /// value as it is (a number stays a number); anything else gives text.
  Object? interpolate(String input, int depth) {
    if (depth > _maxDepth) {
      throw StateError('formatString: expressions nested too deeply');
    }
    var i = 0;
    final parts = <Object?>[];
    // Whether each part is an expression's value rather than literal text.
    final isValue = <bool>[];

    while (i < input.length) {
      final int startIndex = input.indexOf(r'${', i);
      if (startIndex == -1) {
        parts.add(input.substring(i));
        isValue.add(false);
        break;
      }

      if (startIndex > 0 && input[startIndex - 1] == r'\') {
        parts
          ..add(input.substring(i, startIndex - 1))
          ..add(r'${');
        isValue
          ..add(false)
          ..add(false);
        i = startIndex + 2;
        continue;
      }

      if (startIndex > i) {
        parts.add(input.substring(i, startIndex));
        isValue.add(false);
      }

      final (String content, int endIndex) = _expressionContent(
        input,
        startIndex + 2,
      );
      if (endIndex == -1) {
        parts.add(input.substring(startIndex));
        isValue.add(false);
        break;
      }

      parts.add(_evaluate(content, depth + 1));
      isValue.add(true);
      i = endIndex + 1; // Skip the closing '}'.
    }

    if (parts.isEmpty) return '';
    if (parts.length == 1 && isValue[0]) return parts[0];
    return parts.map((part) => part?.toString() ?? '').join();
  }

  /// The text of the expression that starts at [start] (after its `${`),
  /// and the index of its closing `}`; `('', -1)` if it is never closed.
  /// Braces inside quoted text don't count.
  (String, int) _expressionContent(String input, int start) {
    var balance = 1;
    var i = start;
    while (i < input.length) {
      if (input[i] == '{') {
        balance++;
      } else if (input[i] == '}') {
        balance--;
        if (balance == 0) {
          return (input.substring(start, i), i);
        }
      }
      if (input[i] == "'" || input[i] == '"') {
        final String quote = input[i];
        i++;
        while (i < input.length) {
          if (input[i] == quote && input[i - 1] != r'\') break;
          i++;
        }
      }
      i++;
    }
    return ('', -1);
  }

  /// The value of one expression: a function call or a data-model path.
  Object? _evaluate(String content, int depth) {
    if (depth > _maxDepth) {
      throw StateError('formatString: expressions nested too deeply');
    }
    final String expression = content.trim();
    final RegExpMatch? match = _call.firstMatch(expression);
    if (match != null && expression.endsWith(')')) {
      final String name = match.group(1)!;
      final String argsText = expression.substring(
        match.end,
        expression.length - 1,
      );
      return _callFunction(name, _namedArgs(argsText, depth + 1));
    }
    return _readPath(expression);
  }

  /// Calls the catalog function [name]; `null` if there is none or it fails.
  Object? _callFunction(String name, Map<String, Object?> args) {
    final FunctionImplementation? function = functions[name];
    if (function == null) {
      _log.warning('Function not found: $name');
      return null;
    }
    try {
      final Object? result = function.execute(args, context);
      return result is ReadonlySignal<Object?> ? result.value : result;
    } on Object catch (error) {
      _log.warning('Function $name failed: $error');
      return null;
    }
  }

  /// Reads `name: value, name: value` pairs.
  Map<String, Object?> _namedArgs(String text, int depth) {
    final args = <String, Object?>{};
    var i = 0;

    void skipSpaces() {
      while (i < text.length && text[i].trim().isEmpty) {
        i++;
      }
    }

    while (i < text.length) {
      skipSpaces();
      if (i >= text.length) break;

      final keyStart = i;
      while (i < text.length &&
          text[i] != ':' &&
          text[i] != ' ' &&
          text[i] != ',') {
        i++;
      }
      final String key = text.substring(keyStart, i).trim();

      skipSpaces();
      if (i < text.length && text[i] == ':') {
        i++;
      } else {
        _log.warning('Invalid named argument (missing colon) at $i: $text');
        return args;
      }
      skipSpaces();

      final (Object? value, int nextIndex) = _value(text, i, depth);
      args[key] = value;
      i = nextIndex;

      skipSpaces();
      if (i < text.length && text[i] == ',') i++;
    }
    return args;
  }

  /// Reads one argument value at [start]; returns it and where it ends.
  (Object?, int) _value(String input, int start, int depth) {
    if (start >= input.length) return (null, start);

    final String char = input[start];
    if (char == "'" || char == '"') {
      int i = start + 1;
      while (i < input.length) {
        if (input[i] == char && input[i - 1] != r'\') break;
        i++;
      }
      if (i < input.length) {
        // Quoted text may hold expressions of its own.
        return (interpolate(input.substring(start + 1, i), depth + 1), i + 1);
      }
      return (input.substring(start), input.length);
    }

    if (char == r'$' && start + 1 < input.length && input[start + 1] == '{') {
      final (String content, int end) = _expressionContent(input, start + 2);
      if (end != -1) return (_evaluate(content, depth), end + 1);
    }

    var i = start;
    while (i < input.length) {
      final String c = input[i];
      if (c == ',' ||
          c == ')' ||
          c == '}' ||
          c == ' ' ||
          c == '\t' ||
          c == '\n') {
        break;
      }
      i++;
    }

    final String token = input.substring(start, i);
    if (token == 'true') return (true, i);
    if (token == 'false') return (false, i);
    if (token == 'null') return (null, i);
    final num? number = num.tryParse(token);
    if (number != null) return (number, i);
    return (_readPath(token), i);
  }

  /// The data-model value at [path], absolute or relative to the component.
  Object? _readPath(String path) =>
      context.resolveSignal(context.bindingFor(path.trim())).value;
}
