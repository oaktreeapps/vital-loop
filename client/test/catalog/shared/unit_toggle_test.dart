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

// Tests for the unit switch, e.g. °C / °F.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/shared/widgets/unit_toggle.dart';

void main() {
  testWidgets('tapping a unit reports it', (tester) async {
    final picked = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnitToggle<String>(
            options: const [
              UnitOption('c', '°C', semanticLabel: 'Celsius'),
              UnitOption('f', '°F', semanticLabel: 'Fahrenheit'),
            ],
            selected: 'c',
            onChanged: picked.add,
          ),
        ),
      ),
    );
    expect(find.text('°C'), findsOneWidget);
    await tester.tap(find.text('°F'));
    expect(picked, ['f']);
  });
}
