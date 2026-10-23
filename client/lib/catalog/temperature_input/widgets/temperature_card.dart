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
import '../../../models/vitals/temperature.dart';
import '../../../models/vitals/vital_status.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/unit_toggle.dart';
import 'thermometer.dart';

/// The body temperature card: a header with a °C / °F switch, the reading
/// with its status, and a [Thermometer] to drag.
///
/// The temperature is kept in °C ([tempC], 34–42, in 0.1 steps); the switch
/// only changes how it is shown. Every change is reported, in °C, through
/// [onChanged].
class TemperatureCard extends StatefulWidget {
  /// Creates the card for [tempC], shown first in [initialUnit].
  const TemperatureCard({
    super.key,
    required this.tempC,
    required this.onChanged,
    this.initialUnit = TempUnit.celsius,
    this.label = 'Temperature',
  });

  /// The temperature in °C.
  final double tempC;

  /// Called with the new temperature in °C, rounded to 0.1.
  final ValueChanged<double> onChanged;

  /// The unit shown until the user switches it.
  final TempUnit initialUnit;

  /// The card's title.
  final String label;

  @override
  State<TemperatureCard> createState() => _TemperatureCardState();
}

/// Holds the temperature while it's being dragged, and the shown unit.
class _TemperatureCardState extends State<TemperatureCard> {
  /// The temperature shown, in °C. Updated right away while dragging, so
  /// the card doesn't wait for the data model.
  late double _tempC = roundTempC(widget.tempC);

  /// The unit the temperature is shown in.
  late TempUnit _unit = widget.initialUnit;

  /// Follows a temperature changed from outside, e.g. by the agent.
  @override
  void didUpdateWidget(TemperatureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tempC != oldWidget.tempC) _tempC = roundTempC(widget.tempC);
  }

  /// Sets the temperature to [tempC], rounded to 0.1 °C. A tick of haptic
  /// feedback marks each new value.
  void _setTemp(double tempC) {
    final double rounded = roundTempC(tempC);
    if (rounded == _tempC) return;
    HapticFeedback.selectionClick();
    setState(() => _tempC = rounded);
    widget.onChanged(rounded);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle base =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final VitalStatus status = temperatureStatus(_tempC);
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
                  Icons.device_thermostat_rounded,
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
              UnitToggle<TempUnit>(
                options: const [
                  UnitOption(TempUnit.celsius, '°C', semanticLabel: 'Celsius'),
                  UnitOption(
                    TempUnit.fahrenheit,
                    '°F',
                    semanticLabel: 'Fahrenheit',
                  ),
                ],
                selected: _unit,
                onChanged: (unit) => setState(() => _unit = unit),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // The number and unit: the thermometer's slider already
              // reads them out.
              ExcludeSemantics(
                child: Text(
                  _unit.fromCelsius(_tempC).toStringAsFixed(1),
                  style: base.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: AppColors.text,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ExcludeSemantics(
                child: Text(
                  _unit.symbol,
                  style: base.copyWith(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              StatusChip(
                label: temperatureStatusLabel(status),
                color: status.color,
                background: status.background,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Thermometer(
            tempC: _tempC,
            unit: _unit,
            color: status.color,
            onChanged: _setTemp,
          ),
        ],
      ),
    );
  }
}
