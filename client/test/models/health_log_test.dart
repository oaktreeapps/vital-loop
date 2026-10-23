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

// Tests for today's health log: adding, counting and clearing entries, and
// an entry as the daily summary sends it.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/health_log.dart';

/// An entry for [flow] with [details], logged at a fixed time.
HealthLogEntry _entry(
  String flow,
  String details, {
  String? notes,
  Map<String, Object?> values = const {},
}) => HealthLogEntry(
  flowName: flow,
  category: flow,
  icon: 'body',
  details: details,
  notes: notes,
  values: values,
  loggedAt: DateTime(2026, 9, 26, 9, 30),
);

void main() {
  test('adding entries counts them per flow, oldest first', () {
    final log = HealthLog();
    expect(log.isEmpty, isTrue);

    log
      ..add(_entry('pain', 'Back pain'))
      ..add(_entry('vitals', 'BP 120/80'))
      ..add(_entry('pain', 'Knee pain'));

    expect(log.isEmpty, isFalse);
    expect(log.countFor('pain'), 2);
    expect(log.countFor('vitals'), 1);
    expect(log.countFor('medication'), 0);
    expect(
      [for (final e in log.entries) e.details],
      ['Back pain', 'BP 120/80', 'Knee pain'],
    );
  });

  test('clearing empties the log', () {
    final log = HealthLog()..add(_entry('pain', 'Back pain'));
    log.clear();
    expect(log.isEmpty, isTrue);
    expect(log.entries, isEmpty);
  });

  test('listeners hear every add and clear', () {
    var changes = 0;
    final log = HealthLog()..addListener(() => changes++);
    log
      ..add(_entry('pain', 'Back pain'))
      ..clear();
    expect(changes, 2);
  });

  test('the entries list cannot be changed from outside', () {
    final log = HealthLog()..add(_entry('pain', 'Back pain'));
    expect(() => log.entries.clear(), throwsUnsupportedError);
  });

  test('an entry is sent with its line, time, color and answers', () {
    final HealthLogEntry entry = _entry(
      'pain',
      'Back pain',
      notes: 'After lifting',
      values: {'level': 5},
    );
    expect(entry.toJson(), {
      'category': 'pain',
      'icon': 'body',
      'color': '#2C4A3E',
      'line': 'Back pain',
      'notes': 'After lifting',
      'time': '9:30 AM',
      'values': {'level': 5},
    });
  });

  test('an entry without notes leaves them out', () {
    expect(_entry('pain', 'Back pain').toJson(), isNot(contains('notes')));
  });
}
