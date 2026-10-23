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

import 'vital_status.dart';

// The rules behind BloodSugarInput: the range, the units, the steps and the
// status. Blood sugar is always stored in whole mg/dL; mmol/L is only for
// display.

/// The lowest blood sugar on the band, in mg/dL.
const double minGlucoseMgDl = 40;

/// The highest blood sugar on the band, in mg/dL.
const double maxGlucoseMgDl = 300;

/// The blood sugar shown before the user picks one, in mg/dL.
const double defaultGlucoseMgDl = 98;

/// How many mg/dL make 1 mmol/L of glucose.
const double mgDlPerMmolL = 18;

/// Where the status changes, in mg/dL: low below the first, normal up to the
/// second, elevated below the third, high from the third.
const List<double> glucoseZoneLimits = [70, 140, 200];

/// A unit blood sugar can be shown in.
enum GlucoseUnit {
  /// Milligrams per decilitre, the unit blood sugar is stored in.
  mgDl('mg/dL'),

  /// Millimoles per litre (mg/dL ÷ 18), for display only.
  mmolL('mmol/L');

  /// Creates a unit shown as [symbol].
  const GlucoseUnit(this.symbol);

  /// The unit's symbol, e.g. "mg/dL".
  final String symbol;

  /// [valueMgDl] as text in this unit: whole mg/dL, or mmol/L with one
  /// decimal, e.g. "98" or "5.4".
  String format(double valueMgDl) => this == mgDl
      ? valueMgDl.round().toString()
      : (valueMgDl / mgDlPerMmolL).toStringAsFixed(1);
}

/// [valueMgDl] rounded to a step of [unit] and kept between
/// [minGlucoseMgDl] and [maxGlucoseMgDl].
///
/// The result is whole mg/dL either way. In mmol/L it is first rounded to
/// 0.1 mmol/L, so it shows as exactly that.
double snapGlucose(double valueMgDl, GlucoseUnit unit) {
  double snapped;
  if (unit == GlucoseUnit.mgDl) {
    snapped = valueMgDl.roundToDouble();
  } else {
    final double tenthsOfMmol = (valueMgDl / mgDlPerMmolL * 10).roundToDouble();
    snapped = (tenthsOfMmol / 10 * mgDlPerMmolL).roundToDouble();
  }
  return snapped.clamp(minGlucoseMgDl, maxGlucoseMgDl);
}

/// [valueMgDl] one step up (+1) or down (-1): 1 mg/dL, or 0.1 mmol/L when
/// shown in mmol/L.
double stepGlucose(double valueMgDl, GlucoseUnit unit, int direction) {
  if (unit == GlucoseUnit.mgDl) {
    return snapGlucose(valueMgDl + direction, unit);
  }
  // Step from the shown mmol/L value, so each tap changes it by 0.1.
  final double shownMmol = double.parse(unit.format(valueMgDl));
  return snapGlucose((shownMmol + direction * 0.1) * mgDlPerMmolL, unit);
}

/// The status of a blood sugar in mg/dL: under 70 is low, up to 140 normal,
/// under 200 elevated, 200 or more high. A general guide, not a diagnosis.
VitalStatus glucoseStatus(double valueMgDl) {
  if (valueMgDl < glucoseZoneLimits[0]) return VitalStatus.low;
  if (valueMgDl <= glucoseZoneLimits[1]) return VitalStatus.normal;
  if (valueMgDl < glucoseZoneLimits[2]) return VitalStatus.elevated;
  return VitalStatus.high;
}
