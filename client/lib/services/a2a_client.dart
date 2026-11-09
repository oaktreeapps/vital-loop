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

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'transport.dart';

/// The A2UI v1.0 extension of A2A, which the app asks the agent to use.
const String a2uiExtensionUri = 'https://a2ui.org/a2a-extension/a2ui/v1.0';

/// An error talking A2A to an agent: an HTTP error status, or a JSON-RPC
/// error in the agent's answer.
class A2aException implements Exception {
  /// Creates the error with what went wrong.
  const A2aException(this.message);

  /// What went wrong.
  final String message;

  @override
  String toString() => 'A2aException: $message';
}

/// One event of an agent's streamed answer: the task's `state` (e.g.
/// "working", "input-required" or "failed"; `null` when the event has none)
/// and the `parts` of the message that came with it.
typedef A2aEvent = ({String? state, List<JsonMap> parts});

/// A small A2A client for one conversation with one agent: it sends a user
/// message with the JSON-RPC method `message/stream` and reads the agent's
/// answer as server-sent events.
///
/// It remembers the conversation's task and context ids from the agent's
/// answers and sends them with the next message, so the agent sees one
/// conversation.
class A2aClient {
  /// Creates a client for the agent at [url]. Tests pass their own
  /// [httpClient].
  A2aClient({required this.url, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  /// The agent's JSON-RPC endpoint, e.g. `http://localhost:10002/nutrition`.
  final Uri url;

  final http.Client _http;

  static final Logger _log = Logger('A2aClient');

  static final Random _random = Random();

  /// The id of the conversation's task, once the agent has named it.
  String? taskId;

  /// The id of the conversation, once the agent has named it.
  String? contextId;

  /// The JSON-RPC id of the next request.
  int _requestId = 0;

  /// Sends [parts] (A2A parts such as `{"kind": "text", "text": ...}`) as
  /// one user message, with [metadata], and returns the agent's events until
  /// its answer ends.
  ///
  /// Throws an [A2aException] for an HTTP error status or a JSON-RPC error,
  /// and an [http.ClientException] when the agent can't be reached.
  Stream<A2aEvent> sendMessageStream(
    List<JsonMap> parts, {
    JsonMap metadata = const {},
  }) async* {
    final JsonMap message = {
      'kind': 'message',
      'messageId': _newMessageId(),
      'role': 'user',
      'parts': parts,
      if (taskId != null) 'referenceTaskIds': [taskId],
      if (contextId != null) 'contextId': contextId,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
    final request = http.Request('POST', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'X-A2A-Extensions': a2uiExtensionUri,
      })
      ..body = jsonEncode({
        'jsonrpc': '2.0',
        'method': 'message/stream',
        'params': {'message': message},
        'id': _requestId++,
      });
    _log.fine('message/stream → $url');

    final http.StreamedResponse response = await _http.send(request);
    if (response.statusCode >= 400) {
      final String body = await response.stream.bytesToString();
      throw A2aException('HTTP ${response.statusCode}: $body');
    }

    // Server-sent events: "data:" lines, with an empty line after each event.
    final dataLines = <String>[];
    final Stream<String> lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final String line in lines) {
      if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trim());
      } else if (line.isEmpty && dataLines.isNotEmpty) {
        final A2aEvent? event = _readEvent(dataLines.join('\n'));
        dataLines.clear();
        if (event != null) yield event;
      }
    }
    if (dataLines.isNotEmpty) {
      final A2aEvent? event = _readEvent(dataLines.join('\n'));
      if (event != null) yield event;
    }
  }

  /// Reads one server-sent event's JSON-RPC response, remembering the task
  /// and context ids it names. Returns `null` for a response without a
  /// result.
  A2aEvent? _readEvent(String data) {
    if (data.isEmpty) return null;
    final Object? response = jsonDecode(data);
    if (response is! Map) return null;
    if (response['error'] case final Map<Object?, Object?> error) {
      throw A2aException('${error['code']}: ${error['message']}');
    }
    final Object? result = response['result'];
    if (result is! Map) return null;

    // A task names itself with "id"; its updates name it with "taskId".
    final Object? task = result['kind'] == 'task'
        ? result['id']
        : result['taskId'];
    if (task is String) taskId = task;
    if (result['contextId'] case final String context) contextId = context;

    // A status update carries its message in "status"; a task carries its
    // latest status the same way; a message is the message itself.
    final Object? status = result['status'];
    final Object? message = result['kind'] == 'message'
        ? result
        : status is Map
        ? status['message']
        : null;
    return (
      state: status is Map && status['state'] is String
          ? status['state'] as String
          : null,
      parts: [
        if (message is Map)
          if (message['parts'] case final List<Object?> parts)
            for (final Object? part in parts)
              if (part is Map) part.cast<String, Object?>(),
      ],
    );
  }

  /// A new id for a message, unique enough for one conversation.
  ///
  /// The random part stays below 2^31: in a browser, bit shifts work on 32
  /// bits, so a limit written as `1 << 32` would be 0 there.
  static String _newMessageId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}-'
      '${_random.nextInt(0x7fffffff).toRadixString(16)}';

  /// Closes the HTTP client.
  void close() => _http.close();
}
