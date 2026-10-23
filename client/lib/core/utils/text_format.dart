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

// Turns dates, times and saved answers into short, readable text for the
// screens, the agent and the PDF report.

/// [time] as a 12-hour clock time, e.g. "1:33 PM".
String formatTime(DateTime time) {
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  return '$hour:${time.minute.toString().padLeft(2, '0')} '
      '${time.hour < 12 ? 'AM' : 'PM'}';
}

/// "26 Sep, 1:33 PM" for a `yyyy-MM-ddTHH:mm` value, or the value as is.
String formatDateTime(Object? value) {
  final DateTime? time = value is String ? DateTime.tryParse(value) : null;
  if (time == null) return '${value ?? ''}';
  return '${time.day} ${_months[time.month - 1]}, ${formatTime(time)}';
}

/// [day] as a long, readable date, e.g. "Saturday, 26 September".
///
/// Used as the date line of the daily summary and the PDF report.
String formatDay(DateTime day) {
  const weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', //
    'Friday', 'Saturday', 'Sunday',
  ];
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', //
    'August', 'September', 'October', 'November', 'December',
  ];
  return '${weekdays[day.weekday - 1]}, ${day.day} ${months[day.month - 1]}';
}

/// A list or a value as readable text: lists joined with ", ".
///
/// Empty items are skipped and whole numbers lose their ".0", so `[2.0, '']`
/// becomes "2". `null` becomes an empty string.
String asText(Object? value) => switch (value) {
  null => '',
  final List<Object?> list =>
    list.map(asText).where((t) => t.isNotEmpty).join(', '),
  final num n when n == n.roundToDouble() => '${n.round()}',
  _ => '$value',
};

/// The non-empty [parts] joined with " · ".
///
/// Handy for building one summary line from optional pieces: `null` and
/// blank parts are left out, and each part is trimmed.
String joinParts(Iterable<String?> parts) => parts
    .whereType<String>()
    .map((p) => p.trim())
    .where((p) => p.isNotEmpty)
    .join(' · ');

/// "1:00 PM" for an "HH:mm:ss" time of day, or the value as is.
String formatTimeOfDay(Object? value) {
  final DateTime? time = value is String
      ? DateTime.tryParse('2000-01-01T$value')
      : null;
  return time == null ? asText(value) : formatTime(time);
}

/// Short month names, used by [formatDateTime]. Index 0 is January.
const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
