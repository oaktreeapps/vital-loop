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
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/care_place.dart';
import '../../../models/health_report.dart';
import '../../../services/pdf_report_builder.dart';
import 'chosen_care.dart';

/// Logs each report shared, and any failure.
final Logger _log = Logger('PdfReportCard');

/// The card that `PdfReport` shows on the screen, with buttons to share or
/// preview the PDF, and below it the place the user picked to get care, if
/// any ([ChosenCare]).
class PdfReportCard extends StatefulWidget {
  /// Creates a card for [report] that saves it as [fileName].
  const PdfReportCard({
    super.key,
    required this.report,
    required this.fileName,
  });

  /// The report to show and to turn into a PDF.
  final HealthReport report;

  /// The PDF's file name, with ".pdf", e.g. "health-report.pdf".
  final String fileName;

  /// Creates the state that tracks whether a PDF is being built.
  @override
  State<PdfReportCard> createState() => _PdfReportCardState();
}

/// State for [PdfReportCard]: builds the PDF when a button is tapped.
class _PdfReportCardState extends State<PdfReportCard> {
  /// Whether a PDF is being built or shared right now. While `true`, both
  /// buttons are disabled and "Share PDF" shows a spinner.
  bool _busy = false;

  /// Builds the PDF, then passes its bytes to [use] (share or print).
  ///
  /// [label] names the action in the logs. If anything fails, the error is
  /// logged and the user sees a short message instead of a crash.
  Future<void> _run(String label, Future<void> Function(Uint8List) use) async {
    setState(() => _busy = true);
    try {
      final Uint8List bytes = await buildHealthReportPdf(widget.report);
      _log.info('$label: built ${widget.fileName} (${bytes.length} bytes)');
      await use(bytes);
    } catch (exception, stackTrace) {
      _log.severe('$label failed', exception, stackTrace);
      // The card may be gone (e.g. the user left the screen) by now.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the PDF. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Draws the report card, then the picked place's card if there is one.
  @override
  Widget build(BuildContext context) {
    final CarePlace? place = widget.report.carePlace;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _reportCard(context),
        if (place != null) ChosenCare(place: place),
      ],
    );
  }

  /// The report card: a PDF icon, the report's title, subtitle and entry
  /// count, and the "Share PDF" and "Preview / print" buttons.
  Widget _reportCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int count = widget.report.entries.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.redTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.report.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.report.subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count ${count == 1 ? 'entry' : 'entries'} · A4 PDF',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _run(
                    'Share',
                    (bytes) => Printing.sharePdf(
                      bytes: bytes,
                      filename: widget.fileName,
                    ),
                  ),
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            label: const Text('Share PDF'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _run(
                    'Preview',
                    (bytes) => Printing.layoutPdf(
                      name: widget.fileName,
                      onLayout: (_) async => bytes,
                    ),
                  ),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Preview / print'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
