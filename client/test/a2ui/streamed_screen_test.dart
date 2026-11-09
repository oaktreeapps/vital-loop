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

// Checks how the app takes a screen that is streamed in parts, as the
// backend sends it while Gemini is still writing: each partial screen is
// applied, a value that is merely off still draws, and a component the app
// can't use at all is reported, not drawn.

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/vitalloop_catalog.dart';
import 'package:vitalloop/flows/vitals_flow.dart';

/// An updateComponents with a root Column and [count] Text lines; [last]
/// replaces the last one's properties.
Map<String, Object?> _update(int count, {Map<String, Object?>? last}) => {
  'version': '1.0',
  'updateComponents': {
    'surfaceId': 's',
    'components': [
      {
        'id': 'root',
        'component': 'Column',
        'children': [for (var i = 0; i < count; i++) 't$i'],
      },
      for (var i = 0; i < count; i++)
        last != null && i == count - 1
            ? {'id': 't$i', ...last}
            : {'id': 't$i', 'component': 'Text', 'text': 'Line $i'},
    ],
  },
};

void main() {
  late MessageProcessor<ComponentImplementation> processor;
  late List<A2uiRendererError> errors;

  setUp(() {
    errors = [];
    // Set up like the app's GenUiSession: errors are reported, not thrown.
    processor = MessageProcessor<ComponentImplementation>(
      catalogs: [vitalsFlow.catalog],
      reportErrorsOnly: true,
      onError: errors.add,
    );
    processor.processMessages({
      'version': '1.0',
      'createSurface': {'surfaceId': 's', 'catalogId': vitalLoopCatalogId},
    });
  });

  tearDown(() => processor.dispose());

  /// The ids of the root Column's children the surface holds now.
  List<Object?> rootChildren() =>
      processor.model
              .getSurface('s')!
              .componentsModel
              .get('root')!
              .properties['children']
          as List<Object?>;

  test('each partial screen replaces the one before', () async {
    for (var count = 1; count <= 12; count++) {
      processor.processMessages(_update(count));
      expect(rootChildren(), hasLength(count));
    }
    await pumpEventQueue();
    expect(errors, isEmpty);
    expect(processor.model.getSurface('s')!.componentsModel.size, 13);
  });

  test('a value that is off is applied: the screen still draws', () async {
    processor.processMessages(_update(12));
    // A number where text belongs, as an LLM may write it.
    processor.processMessages(
      _update(13, last: {'component': 'Text', 'text': 12345}),
    );
    await pumpEventQueue();

    expect(errors, isEmpty);
    expect(rootChildren(), hasLength(13));
  });

  test("a component the app can't use is reported and not applied", () async {
    processor.processMessages(_update(12));
    // A Button whose action is no action.
    processor.processMessages(
      _update(
        13,
        last: {'component': 'Button', 'child': 't0', 'action': 'tap'},
      ),
    );
    await pumpEventQueue();

    expect(errors, hasLength(1));
    expect(errors.single.code, 'VALIDATION_FAILED');
    expect(errors.single.surfaceId, 's');
    // The screen stays as the last good update left it.
    expect(rootChildren(), hasLength(12));
  });

  test('a v0.9 message is rejected: the app only speaks v1.0', () async {
    processor.processMessages({
      'version': 'v0.9',
      'createSurface': {'surfaceId': 'old', 'catalogId': vitalLoopCatalogId},
    });
    await pumpEventQueue();
    expect(processor.model.getSurface('old'), isNull);
    expect(errors, isNotEmpty);
  });

  test('a surface without the app\'s catalog id is rejected', () async {
    processor.processMessages({
      'version': '1.0',
      'createSurface': {
        'surfaceId': 'other',
        'catalogId':
            'https://a2ui.org/specification/v1_0/catalogs/basic/catalog.json',
      },
    });
    await pumpEventQueue();
    expect(processor.model.getSurface('other'), isNull);
    expect(errors, isNotEmpty);
  });
}
