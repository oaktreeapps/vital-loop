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

import '../core/utils/text_format.dart';
import 'care_place.dart';

/// One entry in the report.
///
/// `category` is what was logged (e.g. "Pain"), `line` is the entry in one
/// readable line, and `notes` and `time` (e.g. "9:10 AM") are optional.
/// Same fields as `HealthLogEntry.toJson` sends to the agent.
typedef ReportEntry = ({
  String category,
  String line,
  String? notes,
  String? time,
});

/// The report the agent writes: what `PdfReport` turns into a PDF.
///
/// `title` and `subtitle` head the first page, `overview` is the agent's
/// text for the doctor (paragraphs split by a blank line), `entries` lists
/// every log entry, and `disclaimer` is the footer on every page.
/// `carePlace` is the place the user picked on the care nearby screen (or
/// `null`); it is shown on the screen only, not in the PDF. Made by
/// [reportFromJson].
typedef HealthReport = ({
  String title,
  String subtitle,
  String overview,
  List<ReportEntry> entries,
  CarePlace? carePlace,
  String disclaimer,
});

/// The footer used when the agent sends no `disclaimer`. It reminds the
/// reader that the report is not medical advice.
const String _defaultDisclaimer =
    'This report was generated from entries you logged. It is not a '
    'diagnosis or medical advice. Share it with your doctor to discuss '
    'anything that concerns you.';

/// Reads a report from the component's props, tolerating missing fields.
HealthReport reportFromJson(Map<String, Object?> data) {
  // [v] trimmed if it is a string, else empty.
  String text(Object? v) => v is String ? v.trim() : '';
  return (
    title: text(data['title']).isEmpty
        ? 'Daily health report'
        : text(data['title']),
    subtitle: text(data['subtitle']).isEmpty
        ? formatDay(DateTime.now())
        : text(data['subtitle']),
    overview: text(data['overview']),
    entries: [
      if (data['entries'] case final List<Object?> list)
        for (final Object? e in list)
          if (e is Map)
            (
              category: text(e['category']),
              line: text(e['line']),
              notes: text(e['notes']).isEmpty ? null : text(e['notes']),
              time: text(e['time']).isEmpty ? null : text(e['time']),
            ),
    ],
    carePlace: CarePlace.fromJson(data['carePlace']),
    disclaimer: text(data['disclaimer']).isEmpty
        ? _defaultDisclaimer
        : text(data['disclaimer']),
  );
}
