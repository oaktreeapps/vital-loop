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

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:vitalloop/flows/nutrition_flow.dart';
import 'package:vitalloop/services/backend_transport.dart';
import 'package:vitalloop/services/genui_session.dart';

import '../support/flaky_backend.dart';

/// A backend that answers a request (with nothing) only when the test calls
/// [answer], so a test controls how long each request stays in flight.
class _ManualBackend implements Transport {
  /// The text of every request that reached this backend, in order.
  final List<String> requests = [];

  /// No A2UI messages: these tests only look at the requests.
  @override
  Stream<core.A2uiMessage> get incomingMessages => const Stream.empty();

  /// No text either.
  @override
  Stream<String> get incomingText => const Stream.empty();

  /// Completes the request in flight when [answer] is called.
  Completer<void> _answer = Completer<void>();

  /// Records the request's text; it stays in flight until [answer].
  @override
  Future<void> sendRequest(ChatMessage message) {
    final TextPart? text = message.parts.whereType<TextPart>().firstOrNull;
    requests.add(
      text?.text ?? message.parts.uiInteractionParts.single.interaction,
    );
    return _answer.future;
  }

  /// Answers the request in flight.
  void answer() {
    _answer.complete();
    _answer = Completer<void>();
  }

  /// Nothing to clean up.
  @override
  void dispose() {}
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
    final controller = session.surfaceHost as SurfaceController;

    // genui reports a surface it can't draw each time it rebuilds it, and
    // each answer from the backend rebuilds it again: once is enough.
    for (var i = 0; i < 3; i++) {
      controller.reportError(StateError('Catalog not found'), null);
      await pumpEventQueue();
      backend.answer();
      await pumpEventQueue();
    }

    expect(backend.requests, hasLength(1));
    expect(backend.requests.single, contains('"error"'));
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
