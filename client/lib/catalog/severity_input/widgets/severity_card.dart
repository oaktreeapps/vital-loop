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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/severity_level.dart';
import '../../shared/widgets/status_chip.dart';
import 'severity_face.dart';
import 'severity_scale.dart';

/// The severity card: a face and band chip that follow the value, the
/// number with what it means, and a [SeverityScale] to drag or tap.
///
/// Used for symptom severity and for the pain level. Every change is
/// reported through [onChanged].
class SeverityCard extends StatefulWidget {
  /// Creates the card for [value], titled [label].
  const SeverityCard({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Title at the top of the card, e.g. `Severity` or `Pain level`.
  final String label;

  /// The severity, from 1 to 10.
  final int value;

  /// Called with each new severity.
  final ValueChanged<int> onChanged;

  @override
  State<SeverityCard> createState() => _SeverityCardState();
}

/// Holds the severity while it's being dragged.
class _SeverityCardState extends State<SeverityCard> {
  /// The severity shown. Updated right away while dragging, so the card
  /// doesn't wait for the data model.
  late int _severity = clampSeverity(widget.value);

  /// Follows a severity changed from outside, e.g. by the agent.
  @override
  void didUpdateWidget(SeverityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _severity = clampSeverity(widget.value);
    }
  }

  /// Sets the severity to [severity] and reports it, if it is new. A tick
  /// of haptic feedback marks each new value.
  void _setSeverity(int severity) {
    final int clamped = clampSeverity(severity);
    if (clamped == _severity) return;
    HapticFeedback.selectionClick();
    setState(() => _severity = clamped);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle base =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final SeverityLevel band = SeverityLevel.of(_severity);
    final TextStyle caption = base.copyWith(
      fontSize: 12,
      color: AppColors.caption,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: band.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SeverityFace(severity: _severity, color: band.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: base.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.text,
                  ),
                ),
              ),
              StatusChip(
                label: band.label,
                color: band.color,
                background: band.background,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // The scale's slider reads the number and its meaning out.
          ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_severity',
                      style: base.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: AppColors.text,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ 10',
                      style: base.copyWith(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  severityDescription(_severity),
                  style: base.copyWith(
                    fontSize: 14,
                    height: 1.43,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SeverityScale(severity: _severity, onChanged: _setSeverity),
          const SizedBox(height: 12),
          ExcludeSemantics(
            // Each label wraps instead of overflowing on a narrow card.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12,
              children: [
                Flexible(child: Text('1 · Barely noticeable', style: caption)),
                Flexible(
                  child: Text(
                    '10 · Worst imaginable',
                    style: caption,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
