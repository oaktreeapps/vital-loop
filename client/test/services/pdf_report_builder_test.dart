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

// Tests for building the daily health report as a PDF file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/health_report.dart';
import 'package:vitalloop/services/pdf_report_builder.dart';

void main() {
  test('the report builds into a PDF', () async {
    final Uint8List bytes = await buildHealthReportPdf(
      reportFromJson({
        'title': 'Daily health report',
        'subtitle': 'Saturday, 26 September · 2 entries',
        // Typographic characters the built-in PDF font can't draw.
        'overview': 'Pain – eased “later” in the day…',
        'entries': [
          {'category': 'Pain', 'line': 'Lumbar Spine · pain 5/10'},
          {'category': 'Vitals', 'line': '36.8 °C', 'notes': 'After a walk'},
        ],
      }),
    );
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });
}
