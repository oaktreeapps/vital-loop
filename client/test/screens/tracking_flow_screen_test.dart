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

// Tests for the flow screen when something goes wrong: it says why, and
// "Start over" tries again.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/flows/nutrition_flow.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';

import '../support/flaky_backend.dart';

void main() {
  testWidgets('a failed flow shows why, and "Start over" tries again', (
    tester,
  ) async {
    final backend = FlakyBackend();
    await tester.pumpWidget(
      MaterialApp(
        home: TrackingFlowScreen(
          flow: nutritionFlow,
          transportFor: (_) => backend,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('The server is down.'), findsOneWidget);

    backend.works = true;
    await tester.tap(find.text('Start over'));
    await tester.pump();

    expect(backend.requests, 2);
    expect(find.text('Something went wrong'), findsNothing);
  });
}
