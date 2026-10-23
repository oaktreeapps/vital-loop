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

import '../../models/vitals/blood_pressure.dart';
import '../shared/data_binding.dart';
import 'widgets/blood_pressure_card.dart';

/// Blood pressure in mmHg: a card with a ruler for each number.
///
/// See [BloodPressureCard]. Properties: `systolic` and `diastolic`
/// (required; usually bindings like `{"path": "/systolic"}`), whole mmHg
/// from 70 to 200 and 40 to 130; and `label`. Dragging a ruler writes the
/// new number to the bound path. When a value has no binding, it is stored
/// under this component's own path (see [bindingPath]). Starts at 118 / 76
/// when the data model has no value yet.
final CatalogItem bloodPressureInput = CatalogItem(
  name: 'BloodPressureInput',
  dataSchema: S.object(
    description:
        'Blood pressure in mmHg: a card with a systolic and a diastolic '
        'ruler and a Low / Normal / Elevated / High · stage 1 / High · stage '
        '2 status.',
    properties: {
      'systolic': A2uiSchemas.numberReference(
        description: 'Systolic (top) number, 70–200, bound to the data model.',
      ),
      'diastolic': A2uiSchemas.numberReference(
        description:
            'Diastolic (bottom) number, 40–130, bound to the data model.',
      ),
      'label': S.string(
        description: 'Card title. Defaults to "Blood pressure".',
      ),
    },
    required: ['systolic', 'diastolic'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "BloodPressureInput",
        "systolic": {"path": "/systolic"}, "diastolic": {"path": "/diastolic"}}]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return bindNumber(
      itemContext,
      bindingPath(itemContext, data['systolic'], 'systolic'),
      numberOrNull(data['systolic']) ?? defaultSystolic,
      // One binding nested in the other, so the card sees both numbers.
      (systolic, setSystolic) => bindNumber(
        itemContext,
        bindingPath(itemContext, data['diastolic'], 'diastolic'),
        numberOrNull(data['diastolic']) ?? defaultDiastolic,
        (diastolic, setDiastolic) => BloodPressureCard(
          systolic: systolic.round(),
          diastolic: diastolic.round(),
          label: stringOrNull(data['label']) ?? 'Blood pressure',
          onChanged: (newSystolic, newDiastolic) {
            if (newSystolic != systolic) setSystolic(newSystolic);
            if (newDiastolic != diastolic) setDiastolic(newDiastolic);
          },
        ),
      ),
    );
  },
);
