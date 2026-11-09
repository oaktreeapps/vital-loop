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

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'a2a_client.dart';
import 'transport.dart';

/// The Python backend (`server/main.py`).
///
/// An Android emulator reaches the computer's `localhost` as `10.0.2.2`. For
/// a phone, pass the computer's address:
/// `flutter run --dart-define=BACKEND_URL=http://192.168.1.20:10002`.
Uri get backendUrl {
  const fromDefine = String.fromEnvironment('BACKEND_URL');
  if (fromDefine.isNotEmpty) return Uri.parse(fromDefine);
  final bool android =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  return Uri.parse(
    android ? 'http://10.0.2.2:10002' : 'http://localhost:10002',
  );
}

/// [server] with [path] added to its own path.
///
/// Keeps any path [server] already has, so a server behind a proxy works:
/// `http://host/api` and `pain` give `http://host/api/pain`.
Uri serverEndpoint(Uri server, String path) => server.replace(
  pathSegments: [
    ...server.pathSegments.where((segment) => segment.isNotEmpty),
    ...path.split('/'),
  ],
);

/// An error from the backend: it couldn't be reached, or its agent failed.
class BackendException implements Exception {
  /// Creates the error with a [message] for the user and its [cause].
  const BackendException(this.message, {this.cause});

  /// What went wrong, in a sentence the app can show.
  final String message;

  /// The underlying error, for the logs.
  final Object? cause;

  /// The [message] and the [cause], so logs show both.
  @override
  String toString() => cause == null ? message : '$message ($cause)';
}

/// A [Transport] that sends a flow's requests to its agent on the backend
/// (e.g. `http://localhost:10002/nutrition`) over A2A, and passes on the
/// A2UI messages the agent answers with.
class BackendTransport implements Transport {
  /// Creates a transport for the flow named [flowName] (e.g. `nutrition`).
  ///
  /// [serverUrl] is the backend's address; it defaults to [backendUrl]. Tests
  /// pass their own address and [httpClient] here.
  BackendTransport({
    required String flowName,
    Uri? serverUrl,
    http.Client? httpClient,
  }) : this._(serverEndpoint(serverUrl ?? backendUrl, flowName), httpClient);

  /// Creates a transport for the flow's agent at `url`.
  BackendTransport._(this._url, http.Client? httpClient)
    : _client = A2aClient(url: _url, httpClient: httpClient) {
    _logger.info('created → $_url');
  }

  /// The flow's agent, e.g. `http://localhost:10002/nutrition`.
  final Uri _url;

  /// The A2A client that talks to the flow's agent and keeps the
  /// conversation's ids.
  final A2aClient _client;

  /// Logger for every transport's messages.
  static final Logger _logger = Logger('BackendTransport');

  /// The A2UI message kinds an agent may send in a data part.
  static const Set<String> _a2uiMessageKinds = {
    'createSurface',
    'updateComponents',
    'updateDataModel',
    'deleteSurface',
    'callRendererFunction',
    'agentFunctionResponse',
  };

  /// The task states that mean the agent could not answer.
  static const Set<String> _failedStates = {'failed', 'canceled', 'rejected'};

  /// The source of [incomingMessages].
  final StreamController<JsonMap> _messages = StreamController.broadcast();

  /// The source of [incomingText].
  final StreamController<String> _text = StreamController.broadcast();

  /// The A2UI messages the agent streams back (create surface, update
  /// components, ...), in the order they arrive.
  @override
  Stream<JsonMap> get incomingMessages => _messages.stream;

  /// Plain text parts of the agent's answers. The app only logs them.
  @override
  Stream<String> get incomingText => _text.stream;

  /// Sends [request] and waits for the agent's answer, passing on its A2UI
  /// messages and text as they stream in.
  ///
  /// Throws a [BackendException] if the backend can't be reached or reports
  /// an error.
  @override
  Future<void> sendRequest(TransportRequest request) async {
    final JsonMap part = switch (request.data) {
      final JsonMap data => {'kind': 'data', 'data': data},
      null => {'kind': 'text', 'text': request.text ?? ''},
    };
    Object? agentError;
    try {
      final Stream<A2aEvent> events = _client.sendMessageStream([
        part,
      ], metadata: request.metadata);
      await for (final A2aEvent event in events) {
        if (_failedStates.contains(event.state)) {
          agentError = 'A2A Error: ${event.state}: ${event.parts}';
          _logger.severe(agentError);
          continue;
        }
        event.parts.forEach(_passOn);
      }
    } on Exception catch (error) {
      throw BackendException(
        "Can't reach the server at $_url. Check that it is running.",
        cause: error,
      );
    }
    if (agentError != null) {
      throw BackendException(
        "The server couldn't build the next screen. Please try again.",
        cause: agentError,
      );
    }
  }

  /// Passes one part of the agent's message on: an A2UI message (a data
  /// part) to [incomingMessages], text to [incomingText].
  void _passOn(JsonMap part) {
    if (part['data'] case final Map<Object?, Object?> data) {
      if (data.keys.any(_a2uiMessageKinds.contains)) {
        if (!_messages.isClosed) _messages.add(data.cast<String, Object?>());
      } else {
        _logger.warning('A data part without an A2UI message: ${data.keys}');
      }
    } else if (part['text'] case final String text) {
      final String trimmed = text.trim();
      if (trimmed.isNotEmpty && !_text.isClosed) _text.add(trimmed);
    }
  }

  /// Closes the client and the streams. Called by `GenUiSession.dispose`.
  @override
  void dispose() {
    _client.close();
    _messages.close();
    _text.close();
  }
}
