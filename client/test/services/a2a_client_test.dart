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

// Tests for the A2A client and the backend transport on top of it: what
// they send to a flow's agent, and how they read its streamed answer.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vitalloop/services/a2a_client.dart';
import 'package:vitalloop/services/backend_transport.dart';
import 'package:vitalloop/services/transport.dart';

/// One server-sent event holding a JSON-RPC response with [result].
String _event(Map<String, Object?> result) =>
    'data: ${jsonEncode({'jsonrpc': '2.0', 'id': 0, 'result': result})}\n\n';

/// A status update of task `t1` in context `c1`, with [parts] as its message.
Map<String, Object?> _status(String state, List<Map<String, Object?>> parts) =>
    {
      'kind': 'status-update',
      'taskId': 't1',
      'contextId': 'c1',
      'status': {
        'state': state,
        'message': {'kind': 'message', 'role': 'agent', 'parts': parts},
      },
    };

/// An HTTP client that answers every request with [body] as an event stream
/// and keeps the requests it got in [requests].
MockClient _agent(
  String body,
  List<http.Request> requests, {
  int status = 200,
}) => MockClient((request) async {
  requests.add(request);
  return http.Response(
    body,
    status,
    headers: {'content-type': 'text/event-stream; charset=utf-8'},
  );
});

void main() {
  final Uri url = Uri.parse('http://localhost:10002/vitals');

  group('A2aClient', () {
    test('sends message/stream and asks for the A2UI v1.0 extension', () async {
      final requests = <http.Request>[];
      final client = A2aClient(url: url, httpClient: _agent('', requests));

      await client
          .sendMessageStream(
            [
              {'kind': 'text', 'text': 'Hello'},
            ],
            metadata: {'a2uiRendererCapabilities': <String, Object?>{}},
          )
          .drain<void>();

      final http.Request request = requests.single;
      expect(request.url, url);
      expect(request.headers['X-A2A-Extensions'], a2uiExtensionUri);
      expect(a2uiExtensionUri, endsWith('/a2ui/v1.0'));
      expect(request.headers['Accept'], 'text/event-stream');
      final body = jsonDecode(request.body) as Map<String, Object?>;
      expect(body['method'], 'message/stream');
      final message = (body['params']! as Map)['message'] as Map;
      expect(message['role'], 'user');
      expect(message['parts'], [
        {'kind': 'text', 'text': 'Hello'},
      ]);
      expect(message['metadata'], {
        'a2uiRendererCapabilities': <String, Object?>{},
      });
      // The first message of a conversation names no task or context.
      expect(message.containsKey('contextId'), isFalse);
      expect(message.containsKey('referenceTaskIds'), isFalse);
    });

    test('reads the events and keeps the conversation ids', () async {
      final requests = <http.Request>[];
      final String answer =
          _event({'kind': 'task', 'id': 't1', 'contextId': 'c1'}) +
          _event(
            _status('working', [
              {
                'kind': 'data',
                'data': {'version': '1.0'},
              },
            ]),
          ) +
          _event(_status('input-required', const []));
      final client = A2aClient(url: url, httpClient: _agent(answer, requests));

      final List<A2aEvent> events = await client.sendMessageStream([
        {'kind': 'text', 'text': 'Hello'},
      ]).toList();

      expect(events.map((event) => event.state), [
        null,
        'working',
        'input-required',
      ]);
      expect(events[1].parts.single['data'], {'version': '1.0'});
      expect(client.taskId, 't1');
      expect(client.contextId, 'c1');

      // The next message continues the same conversation.
      await client.sendMessageStream([
        {'kind': 'text', 'text': 'Again'},
      ]).drain<void>();
      final message =
          ((jsonDecode(requests.last.body) as Map)['params'] as Map)['message']
              as Map;
      expect(message['contextId'], 'c1');
      expect(message['referenceTaskIds'], ['t1']);
    });

    test('an HTTP error status and a JSON-RPC error both throw', () async {
      final failing = A2aClient(
        url: url,
        httpClient: _agent('Not found', [], status: 404),
      );
      await expectLater(
        failing.sendMessageStream(const []).drain<void>(),
        throwsA(isA<A2aException>()),
      );

      final error =
          'data: ${jsonEncode({
            'jsonrpc': '2.0',
            'id': 0,
            'error': {'code': -32603, 'message': 'Internal error'},
          })}\n\n';
      final rejecting = A2aClient(url: url, httpClient: _agent(error, []));
      await expectLater(
        rejecting.sendMessageStream(const []).drain<void>(),
        throwsA(
          isA<A2aException>().having(
            (e) => e.message,
            'message',
            contains('Internal error'),
          ),
        ),
      );
    });
  });

  group('BackendTransport', () {
    BackendTransport transport(String answer, List<http.Request> requests) =>
        BackendTransport(
          flowName: 'vitals',
          serverUrl: Uri.parse('http://localhost:10002'),
          httpClient: _agent(answer, requests),
        );

    test(
      'passes on the A2UI messages and text of the answer, in order',
      () async {
        final Map<String, Object> create = {
          'version': '1.0',
          'createSurface': {'surfaceId': 's'},
        };
        final Map<String, Object> update = {
          'version': '1.0',
          'updateComponents': {'surfaceId': 's', 'components': <Object?>[]},
        };
        final String answer =
            _event(
              _status('working', [
                {
                  'kind': 'data',
                  'data': create,
                  'metadata': {'mimeType': 'application/a2ui+json'},
                },
                {'kind': 'text', 'text': '  Here you go.  '},
                // Data that is no A2UI message is not passed on.
                {
                  'kind': 'data',
                  'data': {'note': 'ignored'},
                },
              ]),
            ) +
            _event(
              _status('input-required', [
                {'kind': 'data', 'data': update},
              ]),
            );
        final requests = <http.Request>[];
        final BackendTransport backend = transport(answer, requests);
        addTearDown(backend.dispose);
        final messages = <JsonMap>[];
        final texts = <String>[];
        backend.incomingMessages.listen(messages.add);
        backend.incomingText.listen(texts.add);

        await backend.sendRequest(
          const TransportRequest.data({
            'version': '1.0',
            'action': {'name': 'vitalsEntered', 'context': <String, Object?>{}},
          }),
        );
        await pumpEventQueue();

        expect(messages, [create, update]);
        expect(texts, ['Here you go.']);
        // A tap goes out as a data part, at the flow's own URL.
        expect(requests.single.url.path, '/vitals');
        final message =
            ((jsonDecode(requests.single.body) as Map)['params']
                    as Map)['message']
                as Map;
        expect((message['parts'] as List).single, {
          'kind': 'data',
          'data': {
            'version': '1.0',
            'action': {'name': 'vitalsEntered', 'context': <String, Object?>{}},
          },
        });
      },
    );

    test('a failed task is a BackendException', () async {
      final BackendTransport backend = transport(
        _event(
          _status('failed', [
            {'kind': 'text', 'text': 'Backend error: no API key'},
          ]),
        ),
        [],
      );
      addTearDown(backend.dispose);
      await expectLater(
        backend.sendRequest(const TransportRequest.text('start')),
        throwsA(
          isA<BackendException>().having(
            (e) => e.message,
            'message',
            contains("couldn't build the next screen"),
          ),
        ),
      );
    });

    test('a server that can\'t be reached is a BackendException', () async {
      final backend = BackendTransport(
        flowName: 'vitals',
        serverUrl: Uri.parse('http://localhost:10002'),
        httpClient: MockClient(
          (request) async => throw http.ClientException('Connection refused'),
        ),
      );
      addTearDown(backend.dispose);
      await expectLater(
        backend.sendRequest(const TransportRequest.text('start')),
        throwsA(
          isA<BackendException>().having(
            (e) => e.message,
            'message',
            contains("Can't reach the server"),
          ),
        ),
      );
    });
  });
}
