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
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../models/severity_level.dart';
import '../shared/data_binding.dart';
import 'widgets/severity_card.dart';

/// Symptom severity from 1 to 10, picked on a scale (see [SeverityCard]).
///
/// A catalog component the backend can put on a screen. It reads and writes
/// one number in the data model (the `value` binding). If the model has no
/// number yet, 5 is written there, so saving always sends a severity. Also
/// used by the pain flow for the pain level.
///
/// ```json
/// {"id": "severity", "component": "SeverityInput",
///  "value": {"path": "/severity"}}
/// ```
final CatalogItem severityInput = CatalogItem(
  name: 'SeverityInput',
  dataSchema: S.object(
    description:
        'Severity on a scale of 1-10: A custom catalog widget with a face, '
        'a scale to tap or drag, and a Mild / Moderate / Severe / Worst '
        'label',
    properties: {
      'value': A2uiSchemas.numberReference(
        description: 'Severity from 1 to 10, bound to the data model.',
      ),
      'label': S.string(description: 'Card title. Defaults to "Severity".'),
    },
    required: ['value'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "SeverityInput", "value": {"path": "/severity"}}]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    // Listen to the bound number and rebuild the card when it changes. The
    // scale only offers whole numbers from 1 to 10, so the value is rounded
    // and clamped both ways.
    return bindNumber(
      itemContext,
      bindingPath(itemContext, data['value'], 'value'),
      numberOrNull(data['value']) ?? defaultSeverity,
      (value, update) {
        final int severity = clampSeverity(value);
        if (severity != value) {
          // The model holds a number the scale can't show (e.g. 0, 15 or
          // 3.6); store the one on screen, after this frame like bindNumber.
          WidgetsBinding.instance.addPostFrameCallback((_) => update(severity));
        }
        return SeverityCard(
          label: stringOrNull(data['label']) ?? 'Severity',
          value: severity,
          onChanged: update,
        );
      },
    );
  },
);
