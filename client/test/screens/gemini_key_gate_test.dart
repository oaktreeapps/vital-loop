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

// Tests for the first-run Gemini API key check: the gate that blocks the app
// until the server has a working key, and the dialog that asks for one.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/screens/gemini_key_gate.dart';
import 'package:vitalloop/services/gemini_key_setup.dart';

/// A key the fake server accepts.
const String _goodKey = 'good-key-123';

/// A server whose key answers come from a list, and which accepts [_goodKey].
class _FakeKeySetup implements GeminiKeySetup {
  /// Answers [status] calls with [answers] in order (the last one repeats).
  /// A null answer means "server unreachable".
  _FakeKeySetup(this.answers);

  /// The answers to give, in order.
  final List<GeminiKeyStatus?> answers;

  /// How often [status] was called.
  int statusCalls = 0;

  /// The keys sent to [submit].
  final List<String> submitted = [];

  @override
  Future<GeminiKeyStatus> status() async {
    final GeminiKeyStatus? answer =
        answers[statusCalls.clamp(0, answers.length - 1)];
    statusCalls++;
    if (answer == null) {
      throw const GeminiKeySetupException("Can't reach the server.");
    }
    return answer;
  }

  @override
  Future<void> submit(String key) async {
    submitted.add(key);
    if (key != _goodKey) {
      throw const GeminiKeySetupException('API key not valid.');
    }
  }

  @override
  void close() {}
}

/// A server with no key yet.
const GeminiKeyStatus _missing = GeminiKeyStatus(state: GeminiKeyState.missing);

/// A server with a working key.
const GeminiKeyStatus _ok = GeminiKeyStatus(state: GeminiKeyState.ok);

/// Shows a [GeminiKeyGate] over a button that counts taps, using [setup].
///
/// Returns a function that tells how often the button was tapped.
Future<int Function()> _pumpGate(
  WidgetTester tester,
  GeminiKeySetup setup,
) async {
  var taps = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: GeminiKeyGate(
        setup: setup,
        child: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => taps++,
              child: const Text('App'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return () => taps;
}

/// The dialog's Save button.
Finder get _saveButton =>
    find.widgetWithText(FilledButton, 'Save and continue');

/// Scrolls the dialog to its Save button, which is below the fold on the
/// small test screen, and taps it.
Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(_saveButton);
  await tester.tap(_saveButton);
}

void main() {
  testWidgets('a working key: no dialog, and the app can be used', (
    tester,
  ) async {
    final int Function() taps = await _pumpGate(tester, _FakeKeySetup([_ok]));
    expect(find.byType(Dialog), findsNothing);
    await tester.tap(find.text('App'));
    expect(taps(), 1);
  });

  testWidgets('no key: the dialog asks for one, and the app waits', (
    tester,
  ) async {
    final setup = _FakeKeySetup([_missing]);
    final int Function() taps = await _pumpGate(tester, setup);

    expect(find.text('Add your Gemini API key'), findsOneWidget);
    expect(find.text(GeminiKeyStatus.defaultKeyUrl), findsOneWidget);
    // Save stays off until a key is typed.
    expect(tester.widget<FilledButton>(_saveButton).onPressed, isNull);
    // The app behind the dialog can't be used yet.
    await tester.tap(find.text('App'), warnIfMissed: false);
    expect(taps(), 0);

    await tester.enterText(find.byType(TextField), '  $_goodKey  ');
    await tester.pump();
    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(setup.submitted, [_goodKey]);
    expect(find.byType(Dialog), findsNothing);
    await tester.tap(find.text('App'));
    expect(taps(), 1);
  });

  testWidgets('a rejected key: the reason shows and the dialog stays', (
    tester,
  ) async {
    final setup = _FakeKeySetup([_missing]);
    await _pumpGate(tester, setup);

    await tester.enterText(find.byType(TextField), 'wrong-key');
    await tester.pump();
    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('API key not valid.'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);

    // A working key afterwards closes it.
    await tester.enterText(find.byType(TextField), _goodKey);
    await tester.pump();
    await _tapSave(tester);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('a key the server has but Google rejects: says why', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      _FakeKeySetup([
        const GeminiKeyStatus(
          state: GeminiKeyState.invalid,
          message: 'API key expired.',
        ),
      ]),
    );
    expect(find.text('Gemini API key not accepted'), findsOneWidget);
    expect(find.textContaining('API key expired.'), findsOneWidget);
  });

  testWidgets('the key is hidden until "Show key" is tapped', (tester) async {
    await _pumpGate(tester, _FakeKeySetup([_missing]));
    bool obscured() => tester
        .widget<EditableText>(
          find.descendant(
            of: find.byType(TextField),
            matching: find.byType(EditableText),
          ),
        )
        .obscureText;

    expect(obscured(), isTrue);
    await tester.tap(find.byTooltip('Show key'));
    await tester.pump();
    expect(obscured(), isFalse);
  });

  testWidgets('server not running: says so, and Retry checks again', (
    tester,
  ) async {
    final setup = _FakeKeySetup([null, _ok]);
    final int Function() taps = await _pumpGate(tester, setup);

    expect(find.text("Can't reach the server"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(setup.statusCalls, 2);
    expect(find.byType(Dialog), findsNothing);
    await tester.tap(find.text('App'));
    expect(taps(), 1);
  });
}
