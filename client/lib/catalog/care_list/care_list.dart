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

import '../../models/care_place.dart';
import '../shared/care_place_schema.dart';
import '../shared/data_binding.dart';
import 'widgets/care_list_view.dart';

/// A list of places to get care: hospitals, clinics, doctors, pharmacies
/// or any other kind, one card each.
///
/// See [CareListView]. Properties: `places` (required; usually a binding
/// like `{"path": "/places"}`, a list of places as the server's nearby
/// search returns them), `selected` (the picked place's id, usually bound to
/// the same path as a CareMap's `selected`, so tapping a card shows the
/// place on the map), `emptyText` (shown when there are no places), and
/// `title` and `city` for a header above the list (e.g. "PLACES NEARBY" and
/// the city searched). Tapping a card writes its id to `selected`.
final CatalogItem careList = CatalogItem(
  name: 'CareList',
  dataSchema: S.object(
    description:
        'A list of places to get care, one card each with its kind, rating, '
        'why it fits, address and Call / Directions / Website buttons. Use '
        'with a CareMap bound to the same places and selected place.',
    properties: {
      'places': carePlacesSchema(),
      'selected': A2uiSchemas.stringReference(
        description:
            "The picked place's id, bound to the data model and shared "
            'with the CareMap.',
      ),
      'emptyText': S.string(description: 'Shown when there are no places.'),
      'title': S.string(
        description:
            'A header above the list, e.g. "Places nearby"; shown in '
            'capitals. No header without it.',
      ),
      'city': S.string(
        description: 'The city searched, shown on the right of the header.',
      ),
    },
    required: ['places'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "CareList",
        "title": "Places nearby", "city": "Sacramento",
        "places": [
          {"id": "a", "name": "Example General Hospital", "kind": "Hospital",
           "type": "hospital", "lat": 38.5555, "lng": -121.4545,
           "address": "2315 Example Street, Sacramento", "rating": 4.2,
           "ratingCount": 812, "phone": "+1 916-555-0100",
           "reason": "A hospital nearby, for anything that needs care today."}
        ]}]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final Map<String, Object?> data = (itemContext.data as Map)
        .cast<String, Object?>();
    final String selectedPath = bindingPath(
      itemContext,
      data['selected'],
      'selected',
    );
    final String? emptyText = stringOrNull(data['emptyText']);
    final String? title = stringOrNull(data['title']);
    final String? city = stringOrNull(data['city']);
    return BoundList(
      dataContext: itemContext.dataContext,
      value: data['places'],
      builder: (context, places) => BoundString(
        dataContext: itemContext.dataContext,
        value: {'path': selectedPath},
        builder: (context, selected) => CareListView(
          places: carePlacesFrom(places),
          selectedId: selected,
          onSelect: (id) =>
              itemContext.dataContext.update(DataPath(selectedPath), id),
          emptyText: emptyText ?? defaultCareListEmptyText,
          title: title,
          city: city,
        ),
      ),
    );
  },
);
