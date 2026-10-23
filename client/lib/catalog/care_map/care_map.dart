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
import 'widgets/care_map_view.dart';

/// The `center` property: `{"lat", "lng"}`, or a binding to it.
///
/// Not genui's `A2uiSchemas.propertyReference`: it allows "any value" or a
/// binding as one-of, and a binding is also "any value", so a bound center
/// matched both and never passed validation.
final Schema centerSchema = S.combined(
  description:
      'The city center as {"lat", "lng"}, or a binding to it; shown when '
      'there are no places.',
  oneOf: [
    S.object(
      properties: {'lat': S.number(), 'lng': S.number()},
      required: ['lat', 'lng'],
    ),
    A2uiSchemas.dataBindingSchema(),
  ],
);

/// An OpenStreetMap map with a pin for each place to get care nearby.
///
/// See [CareMapView]. Properties: `places` (required; usually a binding like
/// `{"path": "/places"}`, a list of places as the server's nearby search
/// returns them), `selected` (the picked place's id, usually bound to the
/// same path as a CareList's `selected`, so tapping a pin picks the place in
/// the list too), `center` (`{"lat", "lng"}`, shown when there are no
/// places) and `city` (the area searched). Tapping a pin writes its id to
/// `selected`.
final CatalogItem careMap = CatalogItem(
  name: 'CareMap',
  dataSchema: S.object(
    description:
        'A map of places to get care (hospitals, clinics, doctors) with a '
        'pin for each place. Use with a CareList bound to the same places '
        'and selected place.',
    properties: {
      'places': carePlacesSchema(),
      'selected': A2uiSchemas.stringReference(
        description:
            "The picked place's id, bound to the data model and shared "
            'with the CareList.',
      ),
      'center': centerSchema,
      'city': S.string(description: 'The city or area searched.'),
    },
    required: ['places'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "CareMap",
        "places": [
          {"id": "a", "name": "Example General Hospital", "kind": "Hospital",
           "type": "hospital", "lat": 38.5555, "lng": -121.4545},
          {"id": "b", "name": "Example Orthopedic Clinic",
           "kind": "Medical clinic", "type": "medical_clinic",
           "lat": 38.5794, "lng": -121.4903}
        ],
        "city": "Sacramento"}]
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
    return BoundList(
      dataContext: itemContext.dataContext,
      value: data['places'],
      builder: (context, places) => BoundObject(
        dataContext: itemContext.dataContext,
        value: data['center'],
        builder: (context, center) => BoundString(
          dataContext: itemContext.dataContext,
          value: {'path': selectedPath},
          builder: (context, selected) => CareMapView(
            places: carePlacesFrom(places),
            center: geoPointFrom(center),
            city: stringOrNull(data['city']),
            selectedId: selected,
            onSelect: (id) =>
                itemContext.dataContext.update(DataPath(selectedPath), id),
          ),
        ),
      ),
    );
  },
);
