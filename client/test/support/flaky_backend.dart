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

// A fake backend whose requests fail until the test says they work, for the
// tests of what happens when something goes wrong.

import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:genui/genui.dart';
import 'package:vitalloop/services/backend_transport.dart';

/// A backend whose requests fail with [BackendException] until [works] is
/// set, or stay in flight until [answer] is called.
class FlakyBackend implements Transport {
  /// Whether requests succeed (after [answer]) instead of failing.
  bool works = false;

  /// How many requests reached this backend.
  int requests = 0;

  /// Completes the request in flight when [works] is set.
  final Completer<void> _answer = Completer<void>();

  @override
  Stream<core.A2uiMessage> get incomingMessages => const Stream.empty();

  @override
  Stream<String> get incomingText => const Stream.empty();

  @override
  Future<void> sendRequest(ChatMessage message) {
    requests++;
    if (!works) {
      throw const BackendException('The server is down.');
    }
    return _answer.future;
  }

  /// Answers the request in flight.
  void answer() => _answer.complete();

  @override
  void dispose() {}
}
