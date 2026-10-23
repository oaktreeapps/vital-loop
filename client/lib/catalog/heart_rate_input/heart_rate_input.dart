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

import '../../models/vitals/heart_rate.dart';
import '../shared/data_binding.dart';
import 'widgets/heart_rate_card.dart';

/// Heart rate in beats per minute: a card with a beating heart, a scrolling
/// ECG trace to drag, a button to tap along with the pulse, and − / +.
///
/// See [HeartRateCard]. Properties: `value` (required; usually a binding
/// like `{"path": "/heartRate"}`), whole bpm from 40 to 200; and `label`.
/// Starts at 72 bpm when the data model has no value yet. Under 60 is low,
/// over 100 is high.
final CatalogItem heartRateInput = CatalogItem(
  name: 'HeartRateInput',
  dataSchema: S.object(
    description:
        'Resting heart rate in bpm: A custom catalog widget with heart '
        'widget, ECG trace, -/+ buttons, and a label',
    properties: {
      'value': A2uiSchemas.numberReference(
        description: 'The heart rate in bpm, bound to the data model.',
      ),
      'label': S.string(description: 'Card title. Defaults to "Heart rate".'),
    },
    required: ['value'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "HeartRateInput", "value": {"path": "/heartRate"}}]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return bindNumber(
      itemContext,
      bindingPath(itemContext, data['value'], 'value'),
      numberOrNull(data['value']) ?? defaultBpm,
      (value, setValue) => HeartRateCard(
        bpm: value.round(),
        onChanged: setValue,
        label: stringOrNull(data['label']) ?? 'Heart rate',
      ),
    );
  },
);
