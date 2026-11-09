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

// Tests for GenUiSession: it sends only one request at a time to the backend,
// each error report only once, and a failing or abandoned request ends
// cleanly.

import 'dart:async';
import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/vitalloop_catalog.dart';
import 'package:vitalloop/flows/nutrition_flow.dart';
import 'package:vitalloop/services/backend_transport.dart';
import 'package:vitalloop/services/genui_session.dart';
import 'package:vitalloop/services/transport.dart';

import '../support/flaky_backend.dart';

/// A backend that answers a request (with nothing) only when the test calls
/// [answer], so a test controls how long each request stays in flight.
class _ManualBackend implements Transport {
  /// The text of every request that reached this backend, in order.
  final List<String> requests = [];

  /// The A2UI messages a test sends to the app with [send].
  final StreamController<JsonMap> _messages = StreamController.broadcast();

  /// The capabilities the app sent with its last request.
  JsonMap lastMetadata = const {};

  @override
  Stream<JsonMap> get incomingMessages => _messages.stream;

  /// Sends an A2UI [message] to the app, as an agent's answer would.
  void send(JsonMap message) => _messages.add(message);

  /// No text either.
  @override
  Stream<String> get incomingText => const Stream.empty();

  /// Completes the request in flight when [answer] is called.
  Completer<void> _answer = Completer<void>();

  /// Records the request's text; it stays in flight until [answer].
  @override
  Future<void> sendRequest(TransportRequest message) {
    requests.add(message.asText);
    lastMetadata = message.metadata;
    return _answer.future;
  }

  /// Answers the request in flight.
  void answer() {
    _answer.complete();
    _answer = Completer<void>();
  }

  /// Closes the message stream.
  @override
  void dispose() => _messages.close();
}

void main() {
  test('a request started while one is in flight is ignored', () async {
    final backend = _ManualBackend();
    final session = GenUiSession(transport: backend, catalog: nutritionCatalog);
    addTearDown(session.dispose);

    // A rendered surface stays interactive while a request is in flight, so
    // its buttons can submit at any point. Send a second message before the
    // first is answered.
    final Future<void> first = session.sendMessage('one');
    expect(session.isProcessing, isTrue);
    await session.sendMessage('two');
    backend.answer();
    await first;

    // The second request never reached the backend.
    expect(backend.requests, ['one']);
    expect(session.isProcessing, isFalse);
    expect(session.error, isNull);
  });

  test('requests run one after another when awaited', () async {
    final backend = _ManualBackend();
    final session = GenUiSession(transport: backend, catalog: nutritionCatalog);
    addTearDown(session.dispose);

    final Future<void> first = session.sendMessage('one');
    backend.answer();
    await first;
    final Future<void> second = session.sendMessage('two');
    backend.answer();
    await second;

    expect(backend.requests, ['one', 'two']);
    // Responses without A2UI messages create no surfaces.
    expect(session.currentSurfaceId, isNull);
  });

  test('an error report is sent to the backend only once', () async {
    final backend = _ManualBackend();
    final session = GenUiSession(transport: backend, catalog: nutritionCatalog);
    addTearDown(session.dispose);

    // A surface the app can't draw may report the same error each time it
    // is rebuilt, and each answer from the backend rebuilds it again: once
    // is enough.
    for (var i = 0; i < 3; i++) {
      session.processor.model.emitError(
        A2uiRendererError(
          code: 'CATALOG_ERROR',
          surfaceId: 's',
          message: 'Catalog not found',
        ),
      );
      await pumpEventQueue();
      backend.answer();
      await pumpEventQueue();
    }

    expect(backend.requests, hasLength(1));
    expect(backend.requests.single, contains('"error"'));
    expect(backend.requests.single, contains('"version":"1.0"'));
  });

  test(
    'a message the app can\'t use is reported once the request ends',
    () async {
      final backend = _ManualBackend();
      final session = GenUiSession(
        transport: backend,
        catalog: nutritionCatalog,
      );
      addTearDown(session.dispose);

      final Future<void> start = session.sendMessage('start');
      // The answer names a catalog the app doesn't have: no surface.
      backend.send({
        'version': '1.0',
        'createSurface': {
          'surfaceId': 's',
          'catalogId': 'https://example.com/x',
        },
      });
      await pumpEventQueue();
      expect(session.currentSurfaceId, isNull);
      // The report waits for the request in flight.
      expect(backend.requests, ['start']);

      backend.answer();
      await start;
      await pumpEventQueue();
      expect(backend.requests, hasLength(2));
      expect(backend.requests.last, contains('"error"'));
      backend.answer();
      await pumpEventQueue();
      expect(session.isProcessing, isFalse);
    },
  );

  test(
    'messages build surfaces, and a tap goes back as a v1.0 action',
    () async {
      final backend = _ManualBackend();
      final session = GenUiSession(
        transport: backend,
        catalog: nutritionCatalog,
      );
      addTearDown(session.dispose);
      final actions = <UserAction>[];
      session.actions.listen(actions.add);

      backend
        ..send({
          'version': '1.0',
          'createSurface': {'surfaceId': 's', 'catalogId': vitalLoopCatalogId},
        })
        ..send({
          'version': '1.0',
          'updateDataModel': {
            'surfaceId': 's',
            'path': '/',
            'value': {'meal': 'Lunch'},
          },
        })
        ..send({
          'version': '1.0',
          'updateComponents': {
            'surfaceId': 's',
            'components': [
              {
                'id': 'root',
                'component': 'Button',
                'child': 'label',
                'action': {
                  'event': {
                    'name': 'mealTypeSelected',
                    'context': {
                      'mealType': {'@path': '/meal'},
                    },
                  },
                },
              },
              {'id': 'label', 'component': 'Text', 'text': 'Continue'},
            ],
          },
        });
      await pumpEventQueue();
      expect(session.currentSurfaceId, 's');
      expect(session.surfaceFor('s'), isNotNull);

      // What a Button does when tapped.
      await session.surfaceFor('s')!.dispatchAction({
        'event': {
          'name': 'mealTypeSelected',
          'context': {'mealType': 'Lunch'},
        },
      }, 'root');
      await pumpEventQueue();

      expect(actions.single.name, 'mealTypeSelected');
      expect(actions.single.context, {'mealType': 'Lunch'});
      final request = jsonDecode(backend.requests.single) as Map;
      expect(request['version'], '1.0');
      expect((request['action'] as Map)['name'], 'mealTypeSelected');
      expect((request['action'] as Map)['surfaceId'], 's');
      // Every request says which A2UI version and catalog the app renders.
      expect(backend.lastMetadata['a2uiRendererCapabilities'], {
        '1.0': {
          'supportedCatalogIds': [vitalLoopCatalogId],
        },
      });
      backend.answer();
      await pumpEventQueue();

      // A deleteSurface removes it again.
      backend.send({
        'version': '1.0',
        'deleteSurface': {'surfaceId': 's'},
      });
      await pumpEventQueue();
      expect(session.currentSurfaceId, isNull);
    },
  );

  test('actionMessage is a v1.0 action the backend reads as a tap', () {
    expect(jsonDecode(actionMessage('findNearbyCare', {'city': 'Austin'})), {
      'version': '1.0',
      'action': {
        'name': 'findNearbyCare',
        'context': {'city': 'Austin'},
      },
    });
  });

  group('GenUiSession', () {
    test('a failing request sets error and ends processing', () async {
      final backend = FlakyBackend();
      final session = GenUiSession(
        transport: backend,
        catalog: nutritionCatalog,
      );
      addTearDown(session.dispose);

      await session.sendMessage('start');

      expect(session.error, isA<BackendException>());
      expect(session.isProcessing, isFalse);
    });

    test('a request that ends after dispose does not throw', () async {
      final backend = FlakyBackend()..works = true;
      final session = GenUiSession(
        transport: backend,
        catalog: nutritionCatalog,
      );

      final Future<void> request = session.sendMessage('start');
      session.dispose(); // The user left the flow.
      backend.answer();

      await expectLater(request, completes);
    });
  });
}
