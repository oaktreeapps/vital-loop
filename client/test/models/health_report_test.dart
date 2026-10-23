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

// Tests for reading the report the agent writes, with defaults for every
// missing field.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/health_report.dart';

import '../support/care_places.dart';

void main() {
  test('every field is read and trimmed', () {
    final HealthReport report = reportFromJson({
      'title': ' My report ',
      'subtitle': 'Saturday, 26 September',
      'overview': 'A calm day.',
      'entries': [
        {'category': 'Pain', 'line': 'Back · 5/10', 'time': '9:10 AM'},
        {'category': 'Vitals', 'line': '36.8 °C', 'notes': ' After a walk '},
      ],
      'disclaimer': 'Not advice.',
    });
    expect(report.title, 'My report');
    expect(report.subtitle, 'Saturday, 26 September');
    expect(report.overview, 'A calm day.');
    expect(report.entries, hasLength(2));
    expect(report.entries.first.time, '9:10 AM');
    expect(report.entries.first.notes, isNull);
    expect(report.entries.last.notes, 'After a walk');
    expect(report.disclaimer, 'Not advice.');
    expect(report.carePlace, isNull);
  });

  test('missing fields get defaults', () {
    final HealthReport report = reportFromJson({});
    expect(report.title, 'Daily health report');
    expect(report.subtitle, isNotEmpty); // Today's date.
    expect(report.overview, '');
    expect(report.entries, isEmpty);
    expect(report.disclaimer, contains('not a diagnosis'));
  });

  test('entries that are not objects are skipped', () {
    final HealthReport report = reportFromJson({
      'entries': [
        'Pain',
        42,
        {'category': 'Pain', 'line': 'Back'},
      ],
    });
    expect([for (final e in report.entries) e.line], ['Back']);
  });

  test('the picked place is read, or nothing', () {
    expect(
      reportFromJson({'carePlace': placeJson('a')}).carePlace?.name,
      'Place a',
    );
    expect(reportFromJson({'carePlace': 'a'}).carePlace, isNull);
  });
}
