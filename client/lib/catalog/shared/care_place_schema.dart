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

/// The `places` property of CareMap and CareList: a list of places (see
/// [CarePlace]), or a binding to one in the data model.
///
/// The places come from the server's nearby search; the server checks each
/// against Google's results before the app gets it.
Schema carePlacesSchema() => A2uiSchemas.listOrReference(
  description:
      'Places to get care, as the nearby search returned them. Usually a '
      'binding like {"path": "/places"}, shared by a CareMap and a CareList.',
  items: carePlaceSchema(),
);

/// One place to get care (see [CarePlace]), as the nearby search returned
/// it. Also PdfReport's `carePlace`, the place the user picked.
Schema carePlaceSchema({String? description}) => S.object(
  description: description,
  properties: {
    'id': S.string(description: "Google's place id."),
    'name': S.string(),
    'kind': S.string(description: 'E.g. "Hospital" or "Orthopedic clinic".'),
    'type': S.string(description: 'Google place type, e.g. "hospital".'),
    'address': S.string(),
    'lat': S.number(),
    'lng': S.number(),
    'rating': S.number(),
    'ratingCount': S.integer(),
    'phone': S.string(),
    'website': S.string(),
    'mapsUrl': S.string(),
    'reason': S.string(description: 'Why the place fits what the user logged.'),
  },
  required: ['id', 'name', 'lat', 'lng'],
);
