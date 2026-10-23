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

// Tests for the box that shows a link or a command with a copy button.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/widgets/key_setup/copy_box.dart';

void main() {
  testWidgets('copying puts the text on the clipboard and says so', (
    tester,
  ) async {
    final copied = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied.add(call.arguments);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CopyBox(
            text: 'https://aistudio.google.com/apikey',
            copyTooltip: 'Copy link',
            link: true,
          ),
        ),
      ),
    );
    expect(find.text('https://aistudio.google.com/apikey'), findsOneWidget);

    await tester.tap(find.byTooltip('Copy link'));
    await tester.pump();
    expect(copied, [
      {'text': 'https://aistudio.google.com/apikey'},
    ]);
    expect(find.byTooltip('Copied'), findsOneWidget);
  });
}
