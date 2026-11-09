// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:a2ui_core/a2ui_core.dart';
import 'package:flutter/material.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

/// What a DateTimeInput lets the user pick, from its JSON properties.
extension type _DateTimeInputData(JsonMap _json) {
  String? get variant => stringOrNull(_json['variant']);

  /// Whether a date is picked: from `variant` ("date" or "datetime"), else
  /// `enableDate`, else yes.
  bool get enableDate {
    final String? v = variant;
    if (v == null) {
      return _json['enableDate'] is bool ? _json['enableDate']! as bool : true;
    }
    return v == 'date' || v == 'datetime';
  }

  /// Whether a time is picked: from `variant` ("time" or "datetime"), else
  /// `enableTime`, else yes.
  bool get enableTime {
    final String? v = variant;
    if (v == null) {
      return _json['enableTime'] is bool ? _json['enableTime']! as bool : true;
    }
    return v == 'time' || v == 'datetime';
  }

  DateTime get firstDate =>
      DateTime.tryParse(stringOrNull(_json['min']) ?? '') ?? DateTime(-9999);

  DateTime get lastDate =>
      DateTime.tryParse(stringOrNull(_json['max']) ?? '') ??
      DateTime(9999, 12, 31);
}

class _DateTimeInput extends StatelessWidget {
  const _DateTimeInput({
    required this.id,
    required this.value,
    required this.path,
    required this.data,
    required this.dataContext,
    this.label,
    this.errorText,
  });

  final String id;
  final String? value;
  final String path;
  final _DateTimeInputData data;
  final DataContext dataContext;
  final String? label;

  /// The message of the first failing check, or `null` when all pass.
  final String? errorText;

  /// Shows the date picker, the time picker or both, then writes the result
  /// to the data model: "yyyy-MM-dd", "HH:mm:00", or a full local date-time.
  Future<void> _handleTap(BuildContext context) async {
    final DateTime initialDate =
        DateTime.tryParse(value ?? '') ??
        DateTime.tryParse('1970-01-01T$value') ??
        DateTime.now();

    var resultDate = initialDate;
    var resultTime = TimeOfDay.fromDateTime(initialDate);

    if (data.enableDate) {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: data.firstDate,
        lastDate: data.lastDate,
      );
      if (pickedDate == null) return;
      resultDate = pickedDate;
    }

    if (data.enableTime) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime == null) return;
      resultTime = pickedTime;
    }

    final finalDateTime = DateTime(
      resultDate.year,
      resultDate.month,
      resultDate.day,
      data.enableTime ? resultTime.hour : 0,
      data.enableTime ? resultTime.minute : 0,
    );

    String formattedValue;
    if (data.enableDate && !data.enableTime) {
      formattedValue = finalDateTime.toIso8601String().split('T').first;
    } else if (!data.enableDate && data.enableTime) {
      final String hour = finalDateTime.hour.toString().padLeft(2, '0');
      final String minute = finalDateTime.minute.toString().padLeft(2, '0');
      formattedValue = '$hour:$minute:00';
    } else {
      formattedValue = finalDateTime.toIso8601String();
    }

    dataContext.set(path, formattedValue);
  }

  String _getDisplayText(MaterialLocalizations localizations) {
    if (value == null) return _getPlaceholderText();
    final DateTime? date =
        DateTime.tryParse(value!) ?? DateTime.tryParse('1970-01-01T$value');
    if (date == null) return value!;

    final List<String> parts = [
      if (data.enableDate) localizations.formatFullDate(date),
      if (data.enableTime)
        localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date)),
    ];
    return parts.join(' ');
  }

  String _getPlaceholderText() {
    if (data.enableDate && data.enableTime) {
      return 'Select a date and time';
    } else if (data.enableDate) {
      return 'Select a date';
    } else if (data.enableTime) {
      return 'Select a time';
    }
    return 'Select a date/time';
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Text(
          _getDisplayText(localizations),
          key: Key('${id}_text'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

/// A field that opens a date picker, a time picker or both.
///
/// `variant` is "date", "time" or "datetime" (the default); the v1.0 basic
/// catalog's `enableDate` and `enableTime` work too. The picked value is
/// written to the bound `value` path as "yyyy-MM-dd", "HH:mm:00" or a full
/// local date-time; without a binding it is kept under this component's own
/// path.
final CatalogItem dateTimeInput = CatalogItem(
  name: 'DateTimeInput',
  description: 'A widget for selecting a date and/or time.',
  isImplicitlyFlexible: true,
  schemaIsComplete: true,
  dataSchema: basicSchema('DateTimeInput', (properties, _) {
    properties['variant'] = {
      'type': 'string',
      'description': 'The input type: date, time, or datetime.',
      'enum': ['date', 'time', 'datetime'],
    };
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final Object? valueRef = data['value'];
    final bool isBound = valueRef is Map && valueRef['@path'] is String;
    final path = isBound
        ? valueRef['@path'] as String
        : '${itemContext.id}.value';
    final String? errorText = itemContext.props.isValid
        ? null
        : itemContext.props.validationErrors.firstOrNull ?? 'Invalid value';

    return BoundString(
      dataContext: itemContext.dataContext,
      value: {'@path': path},
      builder: (context, value) {
        var effectiveValue = value;
        if (effectiveValue == null && !isBound) {
          effectiveValue = stringOrNull(valueRef);
        }
        return BoundString(
          dataContext: itemContext.dataContext,
          value: data['label'],
          builder: (context, label) => _DateTimeInput(
            id: itemContext.id,
            value: effectiveValue,
            path: path,
            data: _DateTimeInputData(data),
            dataContext: itemContext.dataContext,
            label: label,
            errorText: errorText,
          ),
        );
      },
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "DateTimeInput",
          "value": "2026-05-15"
        }
      ]
    ''',
  ],
);
