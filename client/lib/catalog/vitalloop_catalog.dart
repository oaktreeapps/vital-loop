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
import 'package:a2ui_flutter/basic_catalog.dart';

import 'shared/catalog_item.dart';
import 'shared/count_function.dart';

/// The id of VitalLoop's A2UI v1.0 catalog. The server puts it in every
/// `createSurface` (see `CATALOG_ID` in server/streaming.py).
///
/// In A2UI v1.0 an app defines its own catalog. This one is the A2UI basic
/// catalog as a2ui_flutter implements it (all of its components and
/// functions), plus the app's own components (`lib/catalog/`) and its one
/// extra function, `count`.
const String vitalLoopCatalogId =
    'https://github.com/oaktreeapps/vital-loop/catalogs/v1_0/catalog.json';

/// One of a2ui_flutter's basic components as a [CatalogItem], with what the
/// catalog screen shows about it: a [description] and an [example] screen.
CatalogItem _basic(
  ComponentImplementation component,
  String description,
  String example,
) => CatalogItem(
  name: component.name,
  description: description,
  schemaIsComplete: true,
  dataSchema: component.schema,
  widgetBuilder: (itemContext) => component.builder(
    itemContext.buildContext,
    itemContext.node,
    itemContext.props,
    itemContext.buildChild,
  ),
  exampleData: [() => example],
);

/// The A2UI v1.0 basic components, which every flow's screens can use. They
/// are a2ui_flutter's own implementations ([BasicComponents]); the app adds
/// nothing to them but a description and an example for the catalog screen.
final List<CatalogItem> basicCatalogItems = [
  _basic(
    BasicComponents.audioPlayer,
    'An audio player component that plays audio from a given URL.',
    '''
      [
        {
          "id": "root",
          "component": "AudioPlayer",
          "url": "https://upload.wikimedia.org/wikipedia/commons/d/db/Minuet_in_G_%28Beethoven%29%2C_piano.ogg"
        }
      ]
    ''',
  ),
  _basic(
    BasicComponents.button,
    'An interactive button that triggers an action when pressed.',
    '''
      [
        {
          "id": "root",
          "component": "Button",
          "child": "text",
          "action": {"event": {"name": "button_pressed"}}
        },
        {"id": "text", "component": "Text", "text": "Hello World"}
      ]
    ''',
  ),
  _basic(
    BasicComponents.card,
    'A visual container (card) that groups a single child widget.',
    '''
      [
        {"id": "root", "component": "Card", "child": "text"},
        {"id": "text", "component": "Text", "text": "This is a card."}
      ]
    ''',
  ),
  _basic(
    BasicComponents.checkBox,
    'A selectable checkbox used for boolean toggles with a label.',
    '''
      [
        {
          "id": "root",
          "component": "CheckBox",
          "label": "Check me",
          "value": {"@path": "/myValue"}
        }
      ]
    ''',
  ),
  _basic(
    BasicComponents.column,
    'A layout widget that arranges its children vertically.',
    '''
      [
        {
          "id": "root",
          "component": "Column",
          "children": ["advice_text", "advice_options", "submit_button"]
        },
        {
          "id": "advice_text",
          "component": "Text",
          "text": "What kind of advice are you looking for?"
        },
        {
          "id": "advice_options",
          "component": "Text",
          "text": "Some advice options."
        },
        {
          "id": "submit_button",
          "component": "Button",
          "child": "submit_button_text",
          "action": {"event": {"name": "submit"}}
        },
        {"id": "submit_button_text", "component": "Text", "text": "Submit"}
      ]
    ''',
  ),
  _basic(
    BasicComponents.dateTimeInput,
    'A widget for selecting a date and/or time.',
    '''
      [
        {
          "id": "root",
          "component": "DateTimeInput",
          "value": {"@path": "/myDate"},
          "enableDate": true,
          "enableTime": true
        }
      ]
    ''',
  ),
  _basic(
    BasicComponents.divider,
    'A thin horizontal or vertical line used to separate content.',
    '''
      [
        {"id": "root", "component": "Divider"}
      ]
    ''',
  ),
  _basic(
    BasicComponents.icon,
    'Displays an icon from a set of available icons.',
    '''
      [
        {"id": "root", "component": "Icon", "name": "add"}
      ]
    ''',
  ),
  _basic(
    BasicComponents.image,
    'A UI element for displaying image data from a URL.',
    '''
      [
        {
          "id": "root",
          "component": "Image",
          "url": {"@path": "/imageUrl"},
          "variant": "mediumFeature"
        }
      ]
    ''',
  ),
  _basic(BasicComponents.list, 'A scrollable list of child widgets.', '''
      [
        {"id": "root", "component": "List", "children": ["text1", "text2"]},
        {"id": "text1", "component": "Text", "text": "First"},
        {"id": "text2", "component": "Text", "text": "Second"}
      ]
    '''),
  _basic(
    BasicComponents.modal,
    'A modal overlay opened by tapping its trigger.',
    '''
      [
        {
          "id": "root",
          "component": "Modal",
          "trigger": "trigger_text",
          "content": "modal_content"
        },
        {"id": "trigger_text", "component": "Text", "text": "Open Modal"},
        {
          "id": "modal_content",
          "component": "Text",
          "text": "This is a modal."
        }
      ]
    ''',
  ),
  _basic(
    BasicComponents.choicePicker,
    'A component that allows selecting one or more options from a list.',
    '''
      [
        {
          "id": "root",
          "component": "Column",
          "children": ["heading1", "radio", "heading2", "check"]
        },
        {
          "id": "heading1",
          "component": "Text",
          "text": "#### Mutually Exclusive"
        },
        {
          "id": "radio",
          "component": "ChoicePicker",
          "variant": "mutuallyExclusive",
          "label": "Choose one",
          "value": {"@path": "/one"},
          "options": [
            {"label": "A", "value": "A"},
            {"label": "B", "value": "B"}
          ]
        },
        {
          "id": "heading2",
          "component": "Text",
          "text": "#### Multiple Selection"
        },
        {
          "id": "check",
          "component": "ChoicePicker",
          "variant": "multipleSelection",
          "label": "Choose many",
          "value": {"@path": "/multi"},
          "options": [
            {"label": "X", "value": "X"},
            {"label": "Y", "value": "Y"}
          ]
        }
      ]
    ''',
  ),
  _basic(
    BasicComponents.row,
    'A layout widget that arranges its children horizontally.',
    '''
      [
        {"id": "root", "component": "Row", "children": ["text1", "text2"]},
        {"id": "text1", "component": "Text", "text": "First"},
        {"id": "text2", "component": "Text", "text": "Second"}
      ]
    ''',
  ),
  _basic(
    BasicComponents.slider,
    'A slider for selecting a value from a range.',
    '''
      [
        {
          "id": "root",
          "component": "Slider",
          "min": 0,
          "max": 10,
          "value": {"@path": "/myValue"}
        }
      ]
    ''',
  ),
  _basic(
    BasicComponents.tabs,
    'A tab layout to navigate between different child components.',
    '''
      [
        {
          "id": "root",
          "component": "Tabs",
          "tabs": [
            {"title": "Overview", "child": "text1"},
            {"title": "Details", "child": "text2"}
          ]
        },
        {
          "id": "text1",
          "component": "Text",
          "text": "This is a short summary of the item."
        },
        {
          "id": "text2",
          "component": "Text",
          "text": "This is a much longer, more detailed description."
        }
      ]
    ''',
  ),
  _basic(BasicComponents.text, 'A block of styled text.', '''
      [
        {"id": "root", "component": "Text", "text": "Hello World"}
      ]
    '''),
  _basic(BasicComponents.textField, 'A text input field.', '''
      [
        {
          "id": "root",
          "component": "TextField",
          "label": "Enter your name here:",
          "value": {"@path": "/name"},
          "variant": "shortText"
        }
      ]
    '''),
  _basic(BasicComponents.video, 'A video player.', '''
      [
        {
          "id": "root",
          "component": "Video",
          "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        }
      ]
    '''),
];

/// The functions the screens can call: the A2UI v1.0 basic catalog's
/// (`formatString`, `formatDate`, `pluralize`, `required`, `regex`, ...) as
/// a2ui_core implements them, plus the app's own `count`.
List<FunctionImplementation> vitalLoopFunctions() => [
  ...BasicCatalog.v1_0().functions.values,
  CountFunction(),
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
      'A2UI basic catalog plus its own inputs, map, list and report.',
  components: [
    for (final CatalogItem item in [...basicCatalogItems, ...customItems])
      strict ? item.strictImplementation : item.implementation,
  ],
  functions: vitalLoopFunctions(),
  definitions: BasicComponents.api.definitions,
);
