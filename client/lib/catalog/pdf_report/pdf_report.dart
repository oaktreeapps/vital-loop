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

import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../models/health_report.dart';
import '../shared/care_place_schema.dart';
import '../shared/data_binding.dart';
import 'widgets/pdf_report_card.dart';

/// A PDF of the day's health log, written by the agent and built here.
///
/// The agent sends the report's content as props (title, subtitle, overview,
/// entries); the component renders it into a PDF with `package:pdf` and lets
/// the user share or print it (`package:printing`).
///
/// It shows a card with the report's title, subtitle and entry count, and
/// two buttons: "Share PDF" and "Preview / print". Properties: `title`,
/// `overview` and `entries` (required; each entry has `category`, `line`,
/// and optional `notes` and `time`), plus `subtitle`, `carePlace` (the place
/// the user picked on the care nearby screen: shown under the card, not in
/// the PDF; left out when none was picked), `disclaimer` and `fileName`
/// (default "health-report"). It writes nothing to the data model. The PDF
/// is only built when a button is tapped.
final CatalogItem pdfReport = CatalogItem(
  name: 'PdfReport',
  dataSchema: S.object(
    description:
        'A shareable PDF health report: a card with the report\'s title and '
        '"Share PDF" / "Preview" buttons. Its props are the report\'s '
        'content.',
    properties: {
      'title': S.string(description: 'Report title.'),
      'subtitle': S.string(description: 'E.g. the date and entry count.'),
      'overview': S.string(
        description:
            'A detailed overview of the day for the user\'s doctor: plain '
            'text, paragraphs separated by a blank line. Neutral, no '
            'diagnosis or medical advice.',
      ),
      'entries': S.list(
        description: 'Every logged entry, as given.',
        items: S.object(
          properties: {
            'category': S.string(),
            'line': S.string(),
            'notes': S.string(),
            'time': S.string(),
          },
          required: ['category', 'line'],
        ),
      ),
      'carePlace': carePlaceSchema(
        description:
            'The place the user picked to get care, as the nearby search '
            'returned it. Leave it out when none was picked.',
      ),
      'disclaimer': S.string(description: 'Footer text; has a default.'),
      'fileName': S.string(description: 'File name without ".pdf".'),
    },
    required: ['title', 'overview', 'entries'],
  ),
  exampleData: [
    () => '''
      [{"id": "root", "component": "PdfReport",
        "title": "Daily health report",
        "subtitle": "Saturday, 26 September · 2 entries",
        "overview": "You logged pain and your vitals today.",
        "entries": [
          {"category": "Pain", "line": "Lumbar Spine · pain 5/10", "time": "9:10 AM"},
          {"category": "Vitals", "line": "BP 115/75 mmHg · 72 bpm", "time": "9:30 AM"}
        ]}]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final Map<String, Object?> data = (itemContext.data as Map)
        .cast<String, Object?>();
    final HealthReport report = reportFromJson(data);
    // The agent writes the name, so keep only safe characters: no path
    // separators or other characters a file system may reject.
    final String name = (stringOrNull(data['fileName']) ?? '')
        .trim()
        .replaceAll(RegExp(r'[^\w.-]+'), '-');
    final fileName = '${name.isNotEmpty ? name : 'health-report'}.pdf';
    return PdfReportCard(report: report, fileName: fileName);
  },
);
