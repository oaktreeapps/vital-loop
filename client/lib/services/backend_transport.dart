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

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:genui_a2a/genui_a2a.dart';
import 'package:logging/logging.dart';

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
  /// pass their own address here.
  BackendTransport({required String flowName, Uri? serverUrl})
    : this._(serverEndpoint(serverUrl ?? backendUrl, flowName));

  /// Creates a transport for the flow's agent at `url`.
  BackendTransport._(this._url) : _connector = A2uiAgentConnector(url: _url) {
    _logger.info('created → $_url');
  }

  /// The flow's agent, e.g. `http://localhost:10002/nutrition`.
  final Uri _url;

  /// The genui_a2a client that talks A2A to the flow's agent and turns its
  /// answers into A2UI messages and text.
  final A2uiAgentConnector _connector;

  /// Logger for every transport's messages.
  static final Logger _logger = Logger('BackendTransport');

  /// The A2UI messages the agent streams back (create surface, update
  /// components, ...), in the order they arrive.
  @override
  Stream<core.A2uiMessage> get incomingMessages => _connector.stream;

  /// Plain text parts of the agent's answers. The app only logs them.
  @override
  Stream<String> get incomingText => _connector.textStream;

  /// Sends [message] and waits for the agent's answer.
  ///
  /// Throws a [BackendException] if the backend can't be reached or reports
  /// an error.
  @override
  Future<void> sendRequest(ChatMessage message) async {
    // The connector reports backend errors on a separate stream instead of
    // throwing, so listen to it during the request and rethrow afterwards.
    Object? agentError;
    final StreamSubscription<Object> errors = _connector.errorStream.listen(
      (error) => agentError = error,
    );
    try {
      await _connector.connectAndSend(message);
    } on Exception catch (error) {
      throw BackendException(
        "Can't reach the server at $_url. Check that it is running.",
        cause: error,
      );
    } finally {
      await errors.cancel();
    }
    if (agentError != null) {
      throw BackendException(
        "The server couldn't build the next screen. Please try again.",
        cause: agentError,
      );
    }
  }

  /// Closes the connector and its streams. Called by `GenUiSession.dispose`.
  @override
  void dispose() => _connector.dispose();
}
