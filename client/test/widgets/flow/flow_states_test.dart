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

// Tests for a flow's loading and error views.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/widgets/flow/flow_error_view.dart';
import 'package:vitalloop/widgets/flow/flow_loading_view.dart';

/// Shows [child] on a plain screen.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('loading shows a spinner and its label', (tester) async {
    await _pump(tester, const FlowLoadingView(label: 'Preparing your log…'));
    expect(find.text('Preparing your log…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('an error says why, and "Start over" retries', (tester) async {
    var retries = 0;
    await _pump(
      tester,
      FlowErrorView(message: 'The server is down.', onRetry: () => retries++),
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('The server is down.'), findsOneWidget);
    await tester.tap(find.text('Start over'));
    expect(retries, 1);
  });
}
