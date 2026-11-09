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

import 'dart:convert';

/// A JSON object, as A2UI messages are.
typedef JsonMap = Map<String, Object?>;

/// One request from the app to a flow's agent: plain text (e.g. the message
/// that starts a flow) or an A2UI renderer message as JSON (a button tap's
/// `action`, or an `error` report).
class TransportRequest {
  /// A plain-text request.
  const TransportRequest.text(String this.text, {this.metadata = const {}})
    : data = null;

  /// An A2UI renderer message, e.g. `{"version": "1.0", "action": {...}}`.
  const TransportRequest.data(JsonMap this.data, {this.metadata = const {}})
    : text = null;

  /// The text of a text request, else `null`.
  final String? text;

  /// The A2UI renderer message of a data request, else `null`.
  final JsonMap? data;

  /// What goes with the request, outside its content: the A2UI versions and
  /// catalogs the app can render (`a2uiRendererCapabilities`).
  final JsonMap metadata;

  /// The request as text: the text itself, or the data as JSON text.
  String get asText => text ?? jsonEncode(data);
}

/// Carries a flow's requests to its agent and the agent's answers back.
///
/// The app's real transport is `BackendTransport` (A2A to the Python
/// server); tests use fakes.
abstract interface class Transport {
  /// The A2UI messages the agent streams back (createSurface,
  /// updateComponents, ...), as decoded JSON, in the order they arrive.
  Stream<JsonMap> get incomingMessages;

  /// Plain text parts of the agent's answers.
  Stream<String> get incomingText;

  /// Sends [request] and completes when the agent has answered in full.
  Future<void> sendRequest(TransportRequest request);

  /// Frees the transport's resources.
  void dispose();
}
