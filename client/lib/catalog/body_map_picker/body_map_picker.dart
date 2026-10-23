// Copyright 2026 The Daily Health Tracker Authors.
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
//
// Modified by Oaktreeapps in 2026.

import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../core/theme/surface_theme.dart' show parseHexColor;
import '../../models/body_map/body_map.dart';
import '../../models/body_map/ranked_region.dart';
import '../shared/data_binding.dart';
import 'widgets/body_map_picker_view.dart';

/// The `BodyMapPicker` catalog component: the backend puts it on the pain
/// flow's "where does it hurt" step.
///
/// It is bound to a list of strings in the data model (`value`). Each string
/// is the canonical name of a selected region, e.g. `Left Knee`. The schema
/// lists every allowed region id ([regionIds]) so the backend can only
/// suggest regions that exist.
final CatalogItem bodyMapPicker = CatalogItem(
  name: 'BodyMapPicker',
  dataSchema: S.object(
    description:
        'An anatomical figure, front and back, on which the user taps the '
        'areas that hurt. Every region is always tappable; `suggested` only '
        'ranks them and picks the side that opens first. Writes the canonical '
        'area names as a list of strings.',
    properties: {
      'value': A2uiSchemas.stringArrayReference(
        description: 'Data binding for the selected area names.',
      ),
      'suggested': S.list(
        description:
            'Regions most likely to be relevant, most likely first. A '
            'ranking, not a restriction. Ids must come from the enum.',
        items: S.object(
          properties: {
            'id': S.string(
              description: 'Region id, e.g. "back.lumbar_spine".',
              enumValues: regionIds,
            ),
            'label': S.string(
              description:
                  'Optional wording for screen readers. The canonical name '
                  'is stored regardless.',
            ),
          },
          required: ['id'],
        ),
      ),
      'view': S.string(
        description:
            'Which side opens first. Defaults to the side holding most of '
            'the suggestions, else the front.',
        enumValues: ['front', 'back'],
      ),
      'maxSelections': S.number(
        description: 'Optional cap on how many areas can be chosen.',
      ),
      'skinColor': S.string(description: 'Body color, "#RRGGBB".'),
      'selectedColor': S.string(description: 'Selected area color, "#RRGGBB".'),
    },
    required: ['value'],
  ),
  exampleData: [
    () => '''
      [
        { "id": "root", "component": "BodyMapPicker",
          "value": { "path": "/bodyAreas" },
          "view": "back",
          "suggested": [
            { "id": "back.lumbar_spine", "label": "Lower back" },
            { "id": "back.left_buttock" },
            { "id": "back.right_buttock" }
          ] }
      ]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final Map<String, Object?> data = (itemContext.data as Map)
        .cast<String, Object?>();
    // Where the selected names live in the data model. If the backend sent
    // no path, a private one is made from the component id.
    final String path = bindingPath(itemContext, data['value'], 'value');
    final List<RankedRegion> ordered = rankRegions(data['suggested']);
    // A cap below 1 would block every tap, so treat it as no cap.
    final int? max = numberOrNull(data['maxSelections'])?.toInt();
    return BoundList(
      dataContext: itemContext.dataContext,
      value: {'path': path},
      builder: (context, raw) => BodyMapPickerView(
        ordered: ordered,
        // Keep only non-empty names; the model may hold anything.
        selected: [
          for (final Object? item in raw ?? const [])
            if ('${item ?? ''}'.trim() case final String name
                when name.isNotEmpty)
              name,
        ],
        opensOn: BodyView.byId(stringOrNull(data['view'])),
        maxSelections: max != null && max >= 1 ? max : null,
        skinColor: parseHexColor(data['skinColor']),
        selectedColor: parseHexColor(data['selectedColor']),
        onChanged: (next) =>
            itemContext.dataContext.update(DataPath(path), next),
      ),
    );
  },
);
