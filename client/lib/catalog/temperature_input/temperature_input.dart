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

import '../../models/vitals/temperature.dart';
import '../shared/data_binding.dart';
import 'widgets/temperature_card.dart';

/// Body temperature, stored in °C: a card with a thermometer to drag.
///
/// See [TemperatureCard]. Properties: `value` (required; usually a binding
/// like `{"path": "/temperature"}`), always in °C from 34 to 42 in 0.1
/// steps; `unit`, the unit shown first ("celsius" or "fahrenheit"; the user
/// can switch it, and it only changes what is shown); and `label`. Starts at
/// 36.6 °C when the data model has no value yet. Under 35 is low, up to 37.5
/// normal, up to 38.0 elevated, above that a fever.
final CatalogItem temperatureInput = CatalogItem(
  name: 'TemperatureInput',
  dataSchema: S.object(
    description:
        'Body temperature in °C (34–42, 0.1 steps): a card with a draggable '
        'thermometer, a °C / °F switch for display, and a Low / Normal / '
        'Elevated / Fever status.',
    properties: {
      'value': A2uiSchemas.numberReference(
        description:
            'The temperature in °C, bound to the data model. Always °C, '
            'whatever unit is shown.',
      ),
      'unit': S.string(
        description: 'The unit shown first. Defaults to "celsius".',
        enumValues: ['celsius', 'fahrenheit'],
      ),
      'label': S.string(description: 'Card title. Defaults to "Temperature".'),
    },
    required: ['value'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "TemperatureInput", "value": {"path": "/temperature"}}]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return bindNumber(
      itemContext,
      bindingPath(itemContext, data['value'], 'value'),
      numberOrNull(data['value']) ?? defaultTempC,
      (value, setValue) => TemperatureCard(
        tempC: value.toDouble(),
        onChanged: setValue,
        initialUnit: data['unit'] == 'fahrenheit'
            ? TempUnit.fahrenheit
            : TempUnit.celsius,
        label: stringOrNull(data['label']) ?? 'Temperature',
      ),
    );
  },
);
