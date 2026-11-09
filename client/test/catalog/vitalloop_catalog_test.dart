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

// Tests for VitalLoop's A2UI v1.0 catalog: what it declares, and that every
// component's example and every server screen passes its strict checks.

import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema_builder/json_schema_builder.dart' show Schema;
import 'package:vitalloop/catalog/shared/catalog_item.dart';
import 'package:vitalloop/catalog/vitalloop_catalog.dart';
import 'package:vitalloop/core/theme/surface_theme.dart';
import 'package:vitalloop/models/health_option.dart';
import 'package:vitalloop/screens/catalog_screen.dart';
import 'package:vitalloop/services/genui_session.dart';
import 'package:vitalloop/services/transport.dart';

import '../support/fake_backend.dart';

/// A processor that throws on anything a strict A2UI v1.0 renderer rejects.
MessageProcessor<ComponentImplementation> _strictProcessor() {
  final processor = MessageProcessor<ComponentImplementation>(
    catalogs: [vitalLoopCatalog(customItems: customCatalogItems, strict: true)],
    validationConfig: ValidationConfig.strict,
  );
  addTearDown(processor.dispose);
  return processor;
}

void main() {
  test('it is a v1.0 catalog under the app\'s own id', () {
    final CatalogImplementation catalog = vitalLoopCatalog();
    expect(catalog.id, vitalLoopCatalogId);
    expect(catalog.protocolVersion, A2uiProtocolVersion.v1_0);
    expect(a2uiVersion, '1.0');
    final Map<String, Object?> document = catalog.toJson();
    expect(document['catalogId'], vitalLoopCatalogId);
    expect(document['protocolVersion'], '1.0');
  });

  test('it has every basic component and the functions the screens call', () {
    final CatalogImplementation catalog = vitalLoopCatalog();
    expect(
      catalog.components.keys,
      containsAll(BasicCatalog.v1_0().components.keys),
    );
    expect(
      catalog.functions.keys,
      containsAll(BasicCatalog.v1_0().functions.keys),
    );
    // No component is declared twice, e.g. once by the app and once by a
    // flow.
    final CatalogImplementation all = vitalLoopCatalog(
      customItems: customCatalogItems,
    );
    expect(all.components, hasLength(18 + customCatalogItems.length));
  });

  test('every flow uses the same catalog id', () {
    for (final HealthTrackingOption option in HealthTrackingOption.values) {
      expect(option.flow.catalog.id, vitalLoopCatalogId, reason: option.name);
      for (final CatalogItem item in option.flow.customItems) {
        expect(option.flow.catalog.components, contains(item.name));
      }
    }
  });

  for (final CatalogItem item in [
    ...defaultCatalogItems,
    ...customCatalogItems,
  ]) {
    test('${item.name}: its example is a valid v1.0 screen', () {
      final MessageProcessor<ComponentImplementation> processor =
          _strictProcessor();
      processor.processMessages([
        {
          'version': '1.0',
          'createSurface': {'surfaceId': 's', 'catalogId': vitalLoopCatalogId},
        },
        {
          'version': '1.0',
          'updateComponents': {
            'surfaceId': 's',
            'components': jsonDecode(item.exampleData.first()),
          },
        },
      ]);
      final SurfaceModel<ComponentImplementation> surface = processor.model
          .getSurface('s')!;
      expect(surface.componentsModel.get('root'), isNotNull);
      // The example is written the v1.0 way.
      expect(item.exampleData.first(), isNot(contains('"path"')));
    });
  }

  group('a value that is off', () {
    /// Applies a screen with one [component] to a new surface of [catalog];
    /// throws when the catalog rejects it.
    void apply(CatalogImplementation catalog, Map<String, Object?> component) {
      final processor = MessageProcessor<ComponentImplementation>(
        catalogs: [catalog],
      );
      addTearDown(processor.dispose);
      processor.processMessages([
        {
          'version': '1.0',
          'createSurface': {'surfaceId': 's', 'catalogId': vitalLoopCatalogId},
        },
        {
          'version': '1.0',
          'updateComponents': {
            'surfaceId': 's',
            'components': [
              {'id': 'root', ...component},
            ],
          },
        },
      ]);
    }

    final Map<String, Map<String, Object?>> offValues = {
      'an unknown icon name': {'component': 'IconBadge', 'name': 'rocket'},
      'a number as text': {'component': 'Text', 'text': 5},
      'an unknown text variant': {
        'component': 'Text',
        'text': 'Hi',
        'variant': 'title',
      },
      'a size written as text': {
        'component': 'IconBadge',
        'name': 'sun',
        'size': '48',
      },
      'a missing label': {
        'component': 'ChoicePicker',
        'options': <Object?>[],
        'value': <Object?>[],
        'displayStyle': 'pills',
      },
    };

    for (final MapEntry<String, Map<String, Object?>> entry
        in offValues.entries) {
      test('${entry.key} still draws the screen, as it always did', () {
        final CatalogImplementation catalog = vitalLoopCatalog(
          customItems: customCatalogItems,
        );
        expect(() => apply(catalog, entry.value), returnsNormally);
      });
    }

    test('the strict catalog, used to check the server\'s screens, rejects '
        'them', () {
      final CatalogImplementation catalog = vitalLoopCatalog(
        customItems: customCatalogItems,
        strict: true,
      );
      expect(
        () => apply(catalog, offValues['an unknown icon name']!),
        throwsA(isA<A2uiError>()),
      );
      expect(
        () => apply(catalog, offValues['a number as text']!),
        throwsA(isA<A2uiError>()),
      );
    });

    test('a component of another type is still not this component', () {
      final Schema schema = customCatalogItems.first.renderedSchema;
      expect((schema.value['properties']! as Map)['component'], {
        'const': customCatalogItems.first.name,
      });
    });
  });

  group('the server\'s screens', () {
    /// Every A2UI message of [flow]'s first screen, as the backend sends it.
    Future<List<Map<String, Object?>>> startScreen(String flow) async {
      final backend = FakeBackend(flow);
      addTearDown(backend.dispose);
      final messages = <Map<String, Object?>>[];
      backend.incomingMessages.listen(messages.add);
      await backend.sendRequest(const TransportRequest.text('start'));
      await pumpEventQueue();
      return messages;
    }

    for (final HealthTrackingOption option in HealthTrackingOption.values) {
      final String flow = option.flow.name;
      test('$flow: the first screen passes the strict v1.0 checks', () async {
        final List<Map<String, Object?>> messages = await startScreen(flow);
        expect(messages, isNotEmpty);
        // Throws on a v0.9 message, an unknown component, a property that
        // breaks its schema, or a child that doesn't exist.
        _strictProcessor().processMessages([
          for (final Map<String, Object?> message in messages)
            // A first screen may clear surfaces of an earlier run.
            if (!message.containsKey('deleteSurface')) message,
        ]);
      });

      test('$flow: the theme travels in metadata.extensions', () async {
        final MessageProcessor<ComponentImplementation> processor =
            _strictProcessor();
        for (final Map<String, Object?> message in await startScreen(flow)) {
          if (message case {
            'createSurface': final Map<Object?, Object?> create,
          }) {
            // v1.0 has no "theme" in createSurface.
            expect(create.containsKey('theme'), isFalse);
            processor.processMessages(message);
            final SurfaceModel<ComponentImplementation> surface = processor
                .model
                .getSurface(create['surfaceId']! as String)!;
            final Map<String, Object?>? theme = SurfaceTheme.themeOf(surface);
            expect(theme, isNotNull);
            expect(theme!['fontFamily'], 'Open Sans');
            expect(
              parseHexColor((theme['colors']! as Map)['primary']),
              const Color(0xFF2C4A3E),
            );
          }
        }
      });
    }
  });
}
