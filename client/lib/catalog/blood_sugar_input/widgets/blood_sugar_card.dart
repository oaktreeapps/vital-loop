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
import '../../../models/vitals/blood_sugar.dart';
import '../../../models/vitals/vital_status.dart';
import '../../shared/widgets/round_icon_button.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/unit_toggle.dart';
import 'glucose_band.dart';

/// The blood sugar card: a header with a mg/dL / mmol/L switch, the reading
/// between − and + buttons, a [GlucoseBand] to drag, and the normal range
/// with the status.
///
/// The value is kept in whole mg/dL ([valueMgDl], 40–300); the switch only
/// changes how it is shown and the size of a step (1 mg/dL or 0.1 mmol/L).
/// Every change is reported, in mg/dL, through [onChanged].
class BloodSugarCard extends StatefulWidget {
  /// Creates the card for [valueMgDl], shown first in [initialUnit].
  const BloodSugarCard({
    super.key,
    required this.valueMgDl,
    required this.onChanged,
    this.initialUnit = GlucoseUnit.mgDl,
    this.label = 'Blood sugar',
  });

  /// The blood sugar in mg/dL.
  final double valueMgDl;

  /// Called with the new blood sugar in whole mg/dL.
  final ValueChanged<double> onChanged;

  /// The unit shown until the user switches it.
  final GlucoseUnit initialUnit;

  /// The card's title.
  final String label;

  @override
  State<BloodSugarCard> createState() => _BloodSugarCardState();
}

/// Holds the value while it's being changed, and the shown unit.
class _BloodSugarCardState extends State<BloodSugarCard> {
  /// The blood sugar shown, in mg/dL. Updated right away while dragging, so
  /// the card doesn't wait for the data model.
  late double _valueMgDl = snapGlucose(widget.valueMgDl, GlucoseUnit.mgDl);

  /// The unit the blood sugar is shown in.
  late GlucoseUnit _unit = widget.initialUnit;

  /// Follows a value changed from outside, e.g. by the agent.
  @override
  void didUpdateWidget(BloodSugarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valueMgDl != oldWidget.valueMgDl) {
      _valueMgDl = snapGlucose(widget.valueMgDl, GlucoseUnit.mgDl);
    }
  }

  /// Sets the blood sugar to [valueMgDl], rounded to a step of the shown
  /// unit. A tick of haptic feedback marks each new value.
  void _setValue(double valueMgDl) {
    final double snapped = snapGlucose(valueMgDl, _unit);
    if (snapped == _valueMgDl) return;
    HapticFeedback.selectionClick();
    setState(() => _valueMgDl = snapped);
    widget.onChanged(snapped);
  }

  /// Moves one step up (+1) or down (-1).
  void _step(int direction) =>
      _setValue(stepGlucose(_valueMgDl, _unit, direction));

  /// The value as text in the shown unit, e.g. "98 mg/dL".
  String _describe(double valueMgDl) =>
      '${_unit.format(valueMgDl)} ${_unit.symbol}';

  @override
  Widget build(BuildContext context) {
    final TextStyle base =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final VitalStatus status = glucoseStatus(_valueMgDl);
    final bool canDecrease = _valueMgDl > minGlucoseMgDl;
    final bool canIncrease = _valueMgDl < maxGlucoseMgDl;
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
                  color: VitalStatus.normal.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bloodtype_rounded,
                  size: 22,
                  color: AppColors.primary,
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
              UnitToggle<GlucoseUnit>(
                options: const [
                  UnitOption(
                    GlucoseUnit.mgDl,
                    'mg/dL',
                    semanticLabel: 'Milligrams per decilitre',
                  ),
                  UnitOption(
                    GlucoseUnit.mmolL,
                    'mmol/L',
                    semanticLabel: 'Millimoles per litre',
                  ),
                ],
                selected: _unit,
                onChanged: (unit) => setState(() => _unit = unit),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              RoundIconButton(
                icon: Icons.remove_rounded,
                tooltip: 'Decrease',
                onPressed: canDecrease ? () => _step(-1) : null,
              ),
              Expanded(
                // The band's slider already reads the value out.
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _unit.format(_valueMgDl),
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
                        _unit.symbol,
                        style: base.copyWith(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              RoundIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Increase',
                onPressed: canIncrease ? () => _step(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            slider: true,
            label: widget.label,
            value: _describe(_valueMgDl),
            increasedValue: _describe(stepGlucose(_valueMgDl, _unit, 1)),
            decreasedValue: _describe(stepGlucose(_valueMgDl, _unit, -1)),
            onIncrease: canIncrease ? () => _step(1) : null,
            onDecrease: canDecrease ? () => _step(-1) : null,
            child: GlucoseBand(
              valueMgDl: _valueMgDl,
              unit: _unit,
              color: status.color,
              onChanged: _setValue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Normal ${_unit.format(glucoseZoneLimits[0])}–'
                  '${_unit.format(glucoseZoneLimits[1])} ${_unit.symbol}',
                  style: base.copyWith(fontSize: 12, color: AppColors.caption),
                ),
              ),
              StatusChip(
                label: status.label,
                color: status.color,
                background: status.background,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
