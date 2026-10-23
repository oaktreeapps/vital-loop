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

// Tests for the dashboard's options: each opens its own flow, and each flow
// matches its templates on the server.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/health_option.dart';

import '../support/test_utils.dart';

void main() {
  test('each option opens its own flow', () {
    final List<String> names = [
      for (final HealthTrackingOption option in HealthTrackingOption.values)
        option.flow.name,
    ];
    expect(names, ['pain', 'symptoms', 'vitals', 'medication', 'nutrition']);
  });

  test('each option has a title and a subtitle', () {
    for (final HealthTrackingOption option in HealthTrackingOption.values) {
      expect(option.title, isNotEmpty, reason: option.name);
      expect(option.subtitle, isNotEmpty, reason: option.name);
    }
  });

  for (final HealthTrackingOption option in HealthTrackingOption.values) {
    test("the ${option.flow.name} flow's save action is in its server "
        'flow', () {
      final file = File('$serverFlowsDir/${option.flow.name}/flow.json');
      expect(file.existsSync(), isTrue, reason: file.path);
      expect(option.flow.saveAction, isNotNull);
      expect(file.readAsStringSync(), contains('"${option.flow.saveAction}"'));
    });
  }
}
