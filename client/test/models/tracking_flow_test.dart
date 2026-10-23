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

// Tests for turning a flow's saved answers into a health log entry.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/health_log.dart';
import 'package:vitalloop/models/tracking_flow.dart';

/// A flow that saves with "saveTestEntry".
TrackingFlow _flow({String Function(Map<String, Object?>)? describe}) =>
    TrackingFlow(
      name: 'test',
      startMessage: 'Start the test flow',
      loadingLabel: 'Loading…',
      saveAction: 'saveTestEntry',
      category: 'Test',
      describe: describe,
    );

void main() {
  test('only the save action makes an entry', () {
    expect(_flow().entryFor('somethingElse', {'level': 5}), isNull);
    expect(_flow().entryFor('saveTestEntry', {'level': 5}), isNotNull);
  });

  test('the entry has the flow, its line and its answers', () {
    final HealthLogEntry entry = _flow(
      describe: (a) => 'Level ${a['level']}',
    ).entryFor('saveTestEntry', {'level': 5})!;
    expect(entry.flowName, 'test');
    expect(entry.category, 'Test');
    expect(entry.icon, 'check');
    expect(entry.details, 'Level 5');
    expect(entry.values, {'level': 5});
  });

  test('without describe, every answer is joined into one line', () {
    final HealthLogEntry entry = _flow().entryFor('saveTestEntry', {
      'area': 'Back',
      'level': 5.0,
    })!;
    expect(entry.details, 'Back, 5');
  });

  test('notes are trimmed, and blank notes are left out', () {
    HealthLogEntry save(String notes) =>
        _flow().entryFor('saveTestEntry', {'notes': notes})!;
    expect(save('  After lunch ').notes, 'After lunch');
    expect(save('   ').notes, isNull);
  });

  test('a flow without a save action never makes an entry', () {
    final flow = TrackingFlow(
      name: 'summary',
      startMessage: 'Start',
      loadingLabel: 'Loading…',
    );
    expect(flow.entryFor('anything', {}), isNull);
  });
}
