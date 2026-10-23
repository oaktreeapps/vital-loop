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

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/theme/app_colors.dart';
import '../models/health_report.dart';

/// Logger for this file; records each PDF that is built and any failure.
final Logger _log = Logger('PdfReport');

/// Dashes and minus signs, for [_pdfSafe].
final RegExp _dashes = RegExp('[‐-―−]');

/// Curly single quotes and primes, for [_pdfSafe].
final RegExp _singleQuotes = RegExp('[‘’‚′]');

/// Curly double quotes and double primes, for [_pdfSafe].
final RegExp _doubleQuotes = RegExp('[“”„″]');

/// Every character outside Latin-1, for [_pdfSafe].
final RegExp _notLatin1 = RegExp(r'[^\u0000-ÿ]');

/// The built-in PDF fonts cover Latin-1 only; swap the few typographic
/// characters an agent likes to write for plain ones, and drop the rest.
///
/// Only used when the Unicode fonts could not be loaded.
String _pdfSafe(String text) => text
    .replaceAll(_dashes, '-')
    .replaceAll(_singleQuotes, "'")
    .replaceAll(_doubleQuotes, '"')
    .replaceAll('…', '...')
    .replaceAll('•', '·')
    .replaceAll(_notLatin1, '');

/// A PDF theme with Noto Sans, so names and notes in most scripts print as
/// typed.
///
/// The fonts are downloaded (and cached) by `package:printing`. Returns
/// `null` when that fails, e.g. offline; the report then uses the built-in
/// Latin-1 font.
Future<pw.ThemeData?> _unicodeTheme() async {
  try {
    final List<pw.Font> fonts = await Future.wait([
      PdfGoogleFonts.notoSansRegular(),
      PdfGoogleFonts.notoSansBold(),
    ]).timeout(const Duration(seconds: 10));
    // On a failed download, printing returns Helvetica instead of throwing.
    if (fonts.any((font) => font is! pw.TtfFont)) {
      _log.warning('Could not load Noto Sans; using the built-in PDF font');
      return null;
    }
    return pw.ThemeData.withFont(base: fonts[0], bold: fonts[1]);
  } on Exception catch (e) {
    _log.warning('Could not load Noto Sans; using the built-in PDF font: $e');
    return null;
  }
}

/// Builds [report] as an A4 PDF.
///
/// The first page starts with a small "VITALLOOP" label, the title and
/// subtitle, then the overview and one block per entry. The content flows
/// over as many pages as it needs; every page has the disclaimer and a page
/// number in its footer. Text is set in Noto Sans when it can be loaded,
/// else in the built-in font with the text cut down to Latin-1. Returns the
/// file's bytes.
Future<Uint8List> buildHealthReportPdf(HealthReport report) async {
  final pw.ThemeData? theme = await _unicodeTheme();
  // [text] as the report's font can print it.
  String clean(String text) => theme == null ? _pdfSafe(text) : text;

  // Main text, secondary text, headings and divider lines.
  final ink = PdfColor.fromInt(AppColors.text.toARGB32());
  final muted = PdfColor.fromInt(AppColors.textMuted.toARGB32());
  final accent = PdfColor.fromInt(AppColors.primary.toARGB32());
  final line = PdfColor.fromInt(AppColors.border.toARGB32());

  final doc = pw.Document(title: clean(report.title), theme: theme);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 12),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: line)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                clean(report.disclaimer),
                style: pw.TextStyle(fontSize: 8, color: muted),
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: muted),
            ),
          ],
        ),
      ),
      build: (context) => [
        pw.Text(
          'VITALLOOP',
          style: pw.TextStyle(
            fontSize: 9,
            letterSpacing: 1.5,
            color: accent,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          clean(report.title),
          style: pw.TextStyle(
            fontSize: 22,
            color: ink,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          clean(report.subtitle),
          style: pw.TextStyle(fontSize: 11, color: muted),
        ),
        pw.SizedBox(height: 20),
        if (report.overview.isNotEmpty) ...[
          pw.Text(
            'Overview',
            style: pw.TextStyle(
              fontSize: 12,
              color: ink,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          // One block per paragraph, so a long overview flows onto the next
          // page instead of overflowing one box.
          for (final String paragraph in report.overview.split(
            RegExp(r'\n\s*\n'),
          ))
            if (paragraph.trim().isNotEmpty)
              pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.fromLTRB(10, 2, 0, 2),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: accent, width: 2),
                  ),
                ),
                child: pw.Text(
                  clean(paragraph.trim()),
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    color: ink,
                    lineSpacing: 2,
                  ),
                ),
              ),
          pw.SizedBox(height: 12),
        ],
        pw.Text(
          'Entries (${report.entries.length})',
          style: pw.TextStyle(
            fontSize: 12,
            color: ink,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        for (final ReportEntry entry in report.entries)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: line)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        clean(entry.category),
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: accent,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    if (entry.time != null)
                      pw.Text(
                        'Logged ${clean(entry.time!)}',
                        style: pw.TextStyle(fontSize: 9, color: muted),
                      ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  clean(entry.line),
                  style: pw.TextStyle(fontSize: 10.5, color: ink),
                ),
                if (entry.notes != null) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Notes: ${clean(entry.notes!)}',
                    style: pw.TextStyle(fontSize: 9.5, color: muted),
                  ),
                ],
              ],
            ),
          ),
      ],
    ),
  );
  return doc.save();
}
