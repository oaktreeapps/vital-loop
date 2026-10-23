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

// Tests for HttpGeminiKeySetup: reading the server's key status, sending a
// key, and the errors when the server refuses it or is not running.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vitalloop/services/gemini_key_setup.dart';

/// A key the tests send.
const String goodKey = 'good-key-123';

void main() {
  group('HttpGeminiKeySetup', () {
    /// The setup, talking to a fake server that answers with [handler].
    HttpGeminiKeySetup setupWith(
      Future<http.Response> Function(http.Request) handler,
    ) => HttpGeminiKeySetup(
      serverUrl: Uri.parse('http://server:10002'),
      client: MockClient(handler),
    );

    test('reads the key status', () async {
      final HttpGeminiKeySetup setup = setupWith((request) async {
        expect(request.url.toString(), 'http://server:10002/setup/gemini-key');
        return http.Response(
          jsonEncode({
            'state': 'invalid',
            'message': 'API key not valid.',
            'keyUrl': 'https://example.com/key',
          }),
          200,
        );
      });
      final GeminiKeyStatus status = await setup.status();
      expect(status.state, GeminiKeyState.invalid);
      expect(status.message, 'API key not valid.');
      expect(status.keyUrl, 'https://example.com/key');
    });

    test('sends the key as JSON', () async {
      final HttpGeminiKeySetup setup = setupWith((request) async {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {'key': goodKey});
        return http.Response(jsonEncode({'state': 'ok'}), 200);
      });
      await setup.submit(goodKey);
    });

    test("a refused key throws the server's reason", () async {
      final HttpGeminiKeySetup setup = setupWith(
        (_) async => http.Response(
          jsonEncode({'state': 'invalid', 'message': 'API key not valid.'}),
          400,
        ),
      );
      await expectLater(
        setup.submit('wrong'),
        throwsA(
          isA<GeminiKeySetupException>().having(
            (e) => e.message,
            'message',
            'API key not valid.',
          ),
        ),
      );
    });

    test('a server that is not running says where the app looked', () async {
      final HttpGeminiKeySetup setup = setupWith(
        (_) async => throw http.ClientException('Connection refused'),
      );
      await expectLater(
        setup.status(),
        throwsA(
          isA<GeminiKeySetupException>().having(
            (e) => e.message,
            'message',
            contains('http://server:10002'),
          ),
        ),
      );
    });

    /// The setup, talking to a fake server that answers with [response].
    HttpGeminiKeySetup setupAnswering(http.Response response) =>
        HttpGeminiKeySetup(
          serverUrl: Uri.parse('http://server:10002'),
          client: MockClient((_) async => response),
        );

    test('a status that is not HTTP 200 throws instead of "missing"', () {
      final HttpGeminiKeySetup setup = setupAnswering(
        http.Response('Not Found', 404),
      );
      expect(
        setup.status(),
        throwsA(
          isA<GeminiKeySetupException>().having(
            (e) => e.message,
            'message',
            contains('HTTP 404'),
          ),
        ),
      );
    });

    test('fields of the wrong type fall back to their defaults', () async {
      final HttpGeminiKeySetup setup = setupAnswering(
        http.Response(jsonEncode({'state': 'invalid', 'message': 42}), 200),
      );
      final GeminiKeyStatus status = await setup.status();
      expect(status.state, GeminiKeyState.invalid);
      expect(status.message, '');
      expect(status.keyUrl, GeminiKeyStatus.defaultKeyUrl);
    });

    test('a refused key without a JSON reason gets a general message', () {
      final HttpGeminiKeySetup setup = setupAnswering(
        http.Response('Internal Server Error', 500),
      );
      expect(
        setup.submit('some-key'),
        throwsA(
          isA<GeminiKeySetupException>().having(
            (e) => e.message,
            'message',
            'The server refused the key.',
          ),
        ),
      );
    });
  });
}
