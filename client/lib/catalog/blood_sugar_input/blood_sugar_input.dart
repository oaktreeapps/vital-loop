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

import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../models/vitals/blood_sugar.dart';
import '../shared/data_binding.dart';
import 'widgets/blood_sugar_card.dart';

/// Blood sugar (glucose), stored in mg/dL: a card with − and + buttons and
/// a zoned band to drag.
///
/// See [BloodSugarCard]. Properties: `value` (required; usually a binding
/// like `{"path": "/bloodSugar"}`), always in whole mg/dL from 40 to 300;
/// `unit`, the unit shown first ("mg/dL" or "mmol/L"; the user can switch
/// it, and it only changes what is shown); and `label`. Starts at 98 mg/dL
/// when the data model has no value yet. Under 70 is low, up to 140 normal,
/// under 200 elevated, 200 or more high.
final CatalogItem bloodSugarInput = CatalogItem(
  name: 'BloodSugarInput',
  dataSchema: S.object(
    description:
        'Blood sugar in mg/dL: A custom catalog widget with -/+ buttons, a '
        'slider, and a switcher between mg/dL and mmol/L',
    properties: {
      'value': A2uiSchemas.numberReference(
        description:
            'The blood sugar in mg/dL, bound to the data model. Always mg/dL, '
            'whatever unit is shown.',
      ),
      'unit': S.string(
        description: 'The unit shown first. Defaults to "mg/dL".',
        enumValues: ['mg/dL', 'mmol/L'],
      ),
      'label': S.string(description: 'Card title. Defaults to "Blood sugar".'),
    },
    required: ['value'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "BloodSugarInput", "value": {"path": "/bloodSugar"}}]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return bindNumber(
      itemContext,
      bindingPath(itemContext, data['value'], 'value'),
      numberOrNull(data['value']) ?? defaultGlucoseMgDl,
      (value, setValue) => BloodSugarCard(
        valueMgDl: value.toDouble(),
        // Always whole mg/dL: stored as an integer, e.g. 98 rather than 98.0.
        onChanged: (valueMgDl) => setValue(valueMgDl.round()),
        initialUnit: data['unit'] == 'mmol/L'
            ? GlucoseUnit.mmolL
            : GlucoseUnit.mgDl,
        label: stringOrNull(data['label']) ?? 'Blood sugar',
      ),
    );
  },
);
