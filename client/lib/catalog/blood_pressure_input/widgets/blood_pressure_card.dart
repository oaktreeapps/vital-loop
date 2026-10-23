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

import '../../../core/theme/app_colors.dart';
import '../../../models/vitals/blood_pressure.dart';
import '../../shared/widgets/status_chip.dart';
import 'ruler_picker.dart';

/// The blood pressure card: a header with the status, the reading as
/// "systolic / diastolic mmHg", and a [RulerPicker] for each number.
///
/// Both rulers' markers take the status color, so they recolor together as
/// the reading crosses into another range. Every change is reported through
/// [onChanged] with both numbers.
class BloodPressureCard extends StatefulWidget {
  /// Creates the card for [systolic] / [diastolic] mmHg.
  const BloodPressureCard({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.onChanged,
    this.label = 'Blood pressure',
  });

  /// The systolic (top) number, in mmHg.
  final int systolic;

  /// The diastolic (bottom) number, in mmHg.
  final int diastolic;

  /// Called with both numbers whenever one of them changes.
  final void Function(int systolic, int diastolic) onChanged;

  /// The card's title.
  final String label;

  @override
  State<BloodPressureCard> createState() => _BloodPressureCardState();
}

/// Holds both numbers while they're being dragged.
class _BloodPressureCardState extends State<BloodPressureCard> {
  /// The systolic number shown. Updated right away while dragging, so the
  /// card doesn't wait for the data model.
  late int _systolic = widget.systolic.clamp(minSystolic, maxSystolic);

  /// The diastolic number shown.
  late int _diastolic = widget.diastolic.clamp(minDiastolic, maxDiastolic);

  /// Follows numbers changed from outside, e.g. by the agent.
  @override
  void didUpdateWidget(BloodPressureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.systolic != oldWidget.systolic) {
      _systolic = widget.systolic.clamp(minSystolic, maxSystolic);
    }
    if (widget.diastolic != oldWidget.diastolic) {
      _diastolic = widget.diastolic.clamp(minDiastolic, maxDiastolic);
    }
  }

  /// Sets either number and reports both.
  void _update({int? systolic, int? diastolic}) {
    setState(() {
      _systolic = systolic ?? _systolic;
      _diastolic = diastolic ?? _diastolic;
    });
    widget.onChanged(_systolic, _diastolic);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle base =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final BloodPressureStatus status = bloodPressureStatus(
      _systolic,
      _diastolic,
    );
    final TextStyle rowLabel = base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.eyebrow,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.roseTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  size: 22,
                  color: AppColors.rose,
                ),
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
                label: status.label,
                color: status.colors.color,
                background: status.colors.background,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // The rulers read the numbers out to screen readers.
          ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$_systolic / $_diastolic',
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
                  'mmHg',
                  style: base.copyWith(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 36,
                child: ExcludeSemantics(child: Text('SYS', style: rowLabel)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RulerPicker(
                  value: _systolic,
                  min: minSystolic,
                  max: maxSystolic,
                  accentColor: status.colors.color,
                  semanticLabel: 'Systolic, mmHg',
                  onChanged: (value) => _update(systolic: value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 36,
                child: ExcludeSemantics(child: Text('DIA', style: rowLabel)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RulerPicker(
                  value: _diastolic,
                  min: minDiastolic,
                  max: maxDiastolic,
                  accentColor: status.colors.color,
                  semanticLabel: 'Diastolic, mmHg',
                  onChanged: (value) => _update(diastolic: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
