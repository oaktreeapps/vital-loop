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

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';

import 'basic/audio_player.dart';
import 'basic/basic_functions.dart';
import 'basic/basic_schemas.dart';
import 'basic/button.dart';
import 'basic/card.dart';
import 'basic/check_box.dart';
import 'basic/choice_picker.dart';
import 'basic/column.dart';
import 'basic/date_time_input.dart';
import 'basic/divider.dart';
import 'basic/icon.dart';
import 'basic/image.dart';
import 'basic/list.dart';
import 'basic/modal.dart';
import 'basic/row.dart';
import 'basic/slider.dart';
import 'basic/tabs.dart';
import 'basic/text.dart';
import 'basic/text_field.dart';
import 'basic/video.dart';
import 'shared/catalog_item.dart';

/// The id of VitalLoop's A2UI v1.0 catalog. The server puts it in every
/// `createSurface` (see `CATALOG_ID` in server/streaming.py).
///
/// In A2UI v1.0 an app defines its own catalog: this one has the basic
/// components, drawn the way the app always drew them, plus the app's own
/// components (`lib/catalog/`).
const String vitalLoopCatalogId =
    'https://github.com/oaktreeapps/vital-loop/catalogs/v1_0/catalog.json';

/// The basic components every flow's screens can use, drawn the way the app
/// always drew them (`lib/catalog/basic/`).
final List<CatalogItem> basicCatalogItems = [
  audioPlayer,
  button,
  card,
  checkBox,
  column,
  dateTimeInput,
  divider,
  icon,
  image,
  list,
  modal,
  choicePicker,
  row,
  slider,
  tabs,
  text,
  textField,
  video,
];

/// VitalLoop's A2UI v1.0 catalog: the [basicCatalogItems] plus [customItems]
/// (the app's own components a flow's screens use), under
/// [vitalLoopCatalogId], with the functions the screens call.
///
/// The app checks each component against its forgiving schema
/// (`CatalogItem.renderedSchema`). With [strict], the catalog checks against
/// the full schemas instead, as the tests of the server's screens do.
CatalogImplementation vitalLoopCatalog({
  List<CatalogItem> customItems = const [],
  bool strict = false,
}) => CatalogImplementation(
  id: vitalLoopCatalogId,
  protocolVersion: A2uiProtocolVersion.v1_0,
  title: 'VitalLoop',
  description:
      'The components and functions of the VitalLoop health tracker: the '
      'A2UI basic components plus its own inputs, map, list and report.',
  components: [
    for (final CatalogItem item in [...basicCatalogItems, ...customItems])
      strict ? item.strictImplementation : item.implementation,
  ],
  functions: vitalLoopFunctions(),
  definitions: basicSchemaDefinitions,
);
