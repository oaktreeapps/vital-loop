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

// Tests for turning dates, times and saved answers into short text.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/core/utils/text_format.dart';

void main() {
  group('formatTime', () {
    for (final (DateTime time, String text) in [
      (DateTime(2026, 9, 26, 0, 5), '12:05 AM'),
      (DateTime(2026, 9, 26, 9, 30), '9:30 AM'),
      (DateTime(2026, 9, 26, 12), '12:00 PM'),
      (DateTime(2026, 9, 26, 13, 33), '1:33 PM'),
      (DateTime(2026, 9, 26, 23, 59), '11:59 PM'),
    ]) {
      test('$time is "$text"', () => expect(formatTime(time), text));
    }
  });

  group('formatDateTime', () {
    test('a date and time reads as day, month and clock time', () {
      expect(formatDateTime('2026-09-26T13:33'), '26 Sep, 1:33 PM');
    });

    test('anything else is shown as it is', () {
      expect(formatDateTime('yesterday'), 'yesterday');
      expect(formatDateTime(42), '42');
      expect(formatDateTime(null), '');
    });
  });

  test('formatDay writes the weekday, day and month', () {
    expect(formatDay(DateTime(2026, 9, 26)), 'Saturday, 26 September');
    expect(formatDay(DateTime(2026, 1, 1)), 'Thursday, 1 January');
  });

  group('asText', () {
    for (final (Object? value, String text) in [
      (null, ''),
      ('Rice', 'Rice'),
      (2.0, '2'),
      (2.5, '2.5'),
      (72, '72'),
      (['Rice', '', 'Dal'], 'Rice, Dal'),
      ([2.0, ''], '2'),
      (<Object?>[], ''),
    ]) {
      test('$value is "$text"', () => expect(asText(value), text));
    }
  });

  test('joinParts skips empty parts and trims the rest', () {
    expect(joinParts(['Lunch', null, '  ', ' Rice ']), 'Lunch · Rice');
    expect(joinParts([]), '');
  });

  test('formatTimeOfDay reads "HH:mm:ss", else shows the value', () {
    expect(formatTimeOfDay('13:00:00'), '1:00 PM');
    expect(formatTimeOfDay('08:15'), '8:15 AM');
    expect(formatTimeOfDay('after lunch'), 'after lunch');
    expect(formatTimeOfDay(null), '');
  });
}
