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

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'backend_transport.dart';

/// The state of the server's Gemini API key.
enum GeminiKeyState {
  /// The server has a key and Google accepts it: the app can run.
  ok,

  /// The server has no key yet (or only `.env.example`'s placeholder).
  missing,

  /// The server has a key, but Google rejects it (e.g. a wrong or revoked key).
  invalid,
}

/// The server's answer about its Gemini API key.
@immutable
class GeminiKeyStatus {
  /// Creates a status with [state], a [message] to show and the [keyUrl].
  const GeminiKeyStatus({
    required this.state,
    this.message = '',
    this.keyUrl = defaultKeyUrl,
  });

  /// Reads the server's JSON answer, e.g. `{"state": "missing", ...}`.
  ///
  /// Fields that are missing or of the wrong type get their defaults.
  factory GeminiKeyStatus.fromJson(Map<String, Object?> json) =>
      GeminiKeyStatus(
        state: GeminiKeyState.values.firstWhere(
          (state) => state.name == json['state'],
          orElse: () => GeminiKeyState.missing,
        ),
        message: json['message'] is String ? json['message']! as String : '',
        keyUrl: json['keyUrl'] is String
            ? json['keyUrl']! as String
            : defaultKeyUrl,
      );

  /// Where developers create a Gemini API key.
  static const String defaultKeyUrl = 'https://aistudio.google.com/app/apikey';

  /// Whether the key works, is missing, or is rejected.
  final GeminiKeyState state;

  /// Why, in a sentence the app can show (e.g. Google's reason for rejecting
  /// the key). Empty when there is nothing to say.
  final String message;

  /// Where to create a key, to show in the key dialog.
  final String keyUrl;
}

/// An error thrown when the server can't be reached or refuses a key.
class GeminiKeySetupException implements Exception {
  /// Creates the error with a [message] to show the user.
  const GeminiKeySetupException(this.message);

  /// What went wrong, ready to show in the key dialog.
  final String message;

  /// The [message], so logs show it.
  @override
  String toString() => message;
}

/// A service that checks the server's Gemini API key and sends it a new one.
///
/// The app uses [HttpGeminiKeySetup]; tests pass their own.
abstract interface class GeminiKeySetup {
  /// Asks the server whether it has a working key.
  ///
  /// Throws [GeminiKeySetupException] when the server can't be reached.
  Future<GeminiKeyStatus> status();

  /// Sends [key] to the server, which checks it with Google and saves it.
  ///
  /// Throws [GeminiKeySetupException] with the reason when the key is
  /// rejected or the server can't be reached.
  Future<void> submit(String key);

  /// Frees the resources this service holds, e.g. its HTTP client.
  void close();
}

/// A [GeminiKeySetup] over HTTP: `GET` and `POST <server>/setup/gemini-key`
/// (see `server/key_setup.py`).
///
/// The key travels as plain HTTP, which is fine for a server on this computer
/// or an emulator. For a server elsewhere, put it behind HTTPS.
class HttpGeminiKeySetup implements GeminiKeySetup {
  /// Creates a setup for the server at [serverUrl] ([backendUrl] by default),
  /// sending requests through [client] (a new one by default).
  HttpGeminiKeySetup({Uri? serverUrl, http.Client? client})
    : _url = serverEndpoint(serverUrl ?? backendUrl, 'setup/gemini-key'),
      _client = client ?? http.Client(),
      _ownsClient = client == null;

  /// The logger for each check. It never logs the key.
  static final Logger _logger = Logger('GeminiKeySetup');

  /// The server's key setup endpoint.
  final Uri _url;

  /// The HTTP client the requests go through.
  final http.Client _client;

  /// Whether [_client] was created here, so [close] should close it.
  final bool _ownsClient;

  /// How long to wait for the server. Checking a key with Google takes a
  /// second or two, so this leaves plenty of room.
  static const Duration _timeout = Duration(seconds: 20);

  @override
  Future<GeminiKeyStatus> status() async {
    _logger.info('Checking the Gemini API key → GET $_url');
    final http.Response response = await _send(() => _client.get(_url));
    if (response.statusCode != 200) {
      // E.g. 404 from an older server without this endpoint.
      _logger.warning('GET $_url → HTTP ${response.statusCode}');
      throw GeminiKeySetupException(
        'The server at ${_url.replace(path: '')} answered with HTTP '
        "${response.statusCode}. Is it this app's server, and up to date?",
      );
    }
    final status = GeminiKeyStatus.fromJson(_json(response));
    _logger.info('Gemini API key: ${status.state.name}');
    return status;
  }

  @override
  Future<void> submit(String key) async {
    _logger.info('Sending a new Gemini API key → POST $_url');
    final http.Response response = await _send(
      () => _client.post(
        _url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key}),
      ),
    );
    if (response.statusCode == 200) return;
    final String message = GeminiKeyStatus.fromJson(_json(response)).message;
    throw GeminiKeySetupException(
      message.isNotEmpty ? message : 'The server refused the key.',
    );
  }

  @override
  void close() {
    if (_ownsClient) _client.close();
  }

  /// Runs [request], turning "server not running" into a clear message. The
  /// key dialog adds the command that starts the server.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on Exception catch (error) {
      _logger.warning('Could not reach the server at $_url: $error');
      throw GeminiKeySetupException(
        'Nothing answered at ${_url.replace(path: '')}. Check that the server '
        'is running.',
      );
    }
  }

  /// The JSON object in [response]'s body, or `{}` if it has none.
  Map<String, Object?> _json(http.Response response) {
    try {
      final Object? body = jsonDecode(response.body);
      if (body is Map<String, Object?>) return body;
    } on FormatException {
      // Not JSON, e.g. an old server without /setup/gemini-key.
    }
    return {};
  }
}
