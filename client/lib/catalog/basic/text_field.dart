// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

final Logger _log = Logger('TextField');

/// The values of the TextField's `variant` property.
class _Variant {
  static const String longText = 'longText';
  static const String number = 'number';
  static const String obscured = 'obscured';
}

final _numberPattern = RegExp(r'^-?\d*\.?\d*$');

final _numberFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) =>
      _numberPattern.hasMatch(newValue.text) ? newValue : oldValue,
);

const _invalidFormatMessage = 'Invalid format';

class _TextField extends StatefulWidget {
  const _TextField({
    required this.initialValue,
    this.label,
    this.checkError,
    this.variant,
    this.validationRegexp,
    required this.onChanged,
    required this.onSubmitted,
  });

  final String initialValue;
  final String? label;

  /// The message of the first failing check, or `null` when all pass.
  final String? checkError;
  final String? variant;
  final String? validationRegexp;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final TextEditingController _controller;
  String? _formatError;

  String? get _error => widget.checkError ?? _formatError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _formatError = _formatErrorFor(widget.initialValue);
  }

  @override
  void didUpdateWidget(_TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text &&
        !_isSameNumberAsTyped(widget.initialValue)) {
      _controller.text = widget.initialValue;
    }
    // A build follows, so the new error does not need a `setState`.
    _formatError = _formatErrorFor(_controller.text);
  }

  /// The error for [text] when it does not match the `validationRegexp` in
  /// full. An empty field is exempt.
  String? _formatErrorFor(String text) {
    final String? pattern = widget.validationRegexp;
    if (pattern == null || text.isEmpty) return null;
    final RegExp regexp;
    try {
      regexp = RegExp('^(?:$pattern)\$');
    } on FormatException catch (error) {
      _log.warning('Invalid validationRegexp "$pattern": $error');
      return null;
    }
    return regexp.hasMatch(text) ? null : _invalidFormatMessage;
  }

  /// Whether [value] is the number the user typed, written differently (e.g.
  /// "5" for a typed "5."), so the typed text is kept.
  bool _isSameNumberAsTyped(String value) {
    if (widget.variant != _Variant.number) return false;
    final num? parsed = num.tryParse(value);
    return parsed != null && parsed == num.tryParse(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? variant = widget.variant;
    final isObscured = variant == _Variant.obscured;
    final isLongText = variant == _Variant.longText;
    final isNumber = variant == _Variant.number;
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: widget.label, errorText: _error),
      obscureText: isObscured,
      // Suggestions and autocorrect would leak or corrupt a password, and are
      // meaningless for numbers.
      autocorrect: !isObscured && !isNumber,
      enableSuggestions: !isObscured && !isNumber,
      // `null` lets the field grow with its content; obscured text is only
      // valid on a single line.
      maxLines: isLongText ? null : 1,
      minLines: isLongText ? 3 : null,
      keyboardType: switch (variant) {
        _Variant.number => const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        _Variant.longText => TextInputType.multiline,
        _ => TextInputType.text,
      },
      // The keyboard type is only a hint, so numbers are also enforced here,
      // which is what stops non-numeric input on desktop and web.
      inputFormatters: isNumber ? [_numberFormatter] : null,
      onChanged: (val) {
        final String? formatError = _formatErrorFor(val);
        if (formatError != _formatError) {
          setState(() => _formatError = formatError);
        }
        widget.onChanged(val);
      },
      onSubmitted: (val) {
        if (_error == null) widget.onSubmitted(val);
      },
    );
  }
}

/// A text input field.
///
/// `variant` is "shortText" (one line, the default), "longText" (several
/// lines), "number" or "obscured" (e.g. a password). Typing writes the text
/// to the bound `value` path; without a binding it is kept under this
/// component's own path. A failing check's message, or a `validationRegexp`
/// that doesn't match, shows as the field's error.
final CatalogItem textField = CatalogItem(
  name: 'TextField',
  description: 'A text input field.',
  isImplicitlyFlexible: true,
  schemaIsComplete: true,
  dataSchema: basicSchema('TextField', (properties, holder) {
    properties['validationRegexp'] = {'type': 'string'};
    properties['onSubmittedAction'] = {
      r'$ref': r'common_types.json#/$defs/Action',
    };
    holder['required'] = ['component'];
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final Object? valueRef = data['value'];
    final path = valueRef is Map && valueRef['@path'] is String
        ? valueRef['@path'] as String
        : '${itemContext.id}.value';
    final String? variant = stringOrNull(data['variant']);
    final String? checkError = itemContext.props.isValid
        ? null
        : itemContext.props.validationErrors.firstOrNull ?? 'Invalid value';
    final NodeAction? onSubmitted = itemContext.props.action(
      'onSubmittedAction',
    );

    return BoundString(
      dataContext: itemContext.dataContext,
      value: {'@path': path},
      builder: (context, currentValue) => BoundString(
        dataContext: itemContext.dataContext,
        value: data['label'],
        builder: (context, label) {
          final String? effectiveValue =
              currentValue ?? (valueRef is String ? valueRef : null);
          return _TextField(
            initialValue: effectiveValue ?? '',
            label: label,
            checkError: checkError,
            variant: variant,
            validationRegexp: stringOrNull(data['validationRegexp']),
            onChanged: (newValue) {
              if (variant == _Variant.number) {
                final num? numberValue = num.tryParse(newValue);
                if (numberValue != null) {
                  itemContext.dataContext.set(path, numberValue);
                  return;
                }
              }
              itemContext.dataContext.set(path, newValue);
            },
            onSubmitted: (_) {
              if (onSubmitted != null) unawaited(onSubmitted());
            },
          );
        },
      ),
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "TextField",
          "label": "Enter your name here:",
          "variant": "shortText"
        }
      ]
    ''',
  ],
);
