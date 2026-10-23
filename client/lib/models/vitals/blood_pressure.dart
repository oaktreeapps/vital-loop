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

// The rules behind BloodPressureInput: the ranges and the status.

/// The lowest systolic (top) value, in mmHg.
const int minSystolic = 70;

/// The highest systolic (top) value, in mmHg.
const int maxSystolic = 200;

/// The lowest diastolic (bottom) value, in mmHg.
const int minDiastolic = 40;

/// The highest diastolic (bottom) value, in mmHg.
const int maxDiastolic = 130;

/// The systolic value shown before the user picks one.
const int defaultSystolic = 118;

/// The diastolic value shown before the user picks one.
const int defaultDiastolic = 76;

/// Where a blood pressure reading falls: the chip's `label` and its
/// `colors`.
typedef BloodPressureStatus = ({String label, VitalStatus colors});

/// The status of [systolic] / [diastolic] in mmHg.
///
/// Low under 90 / 60; high stage 2 from 140 or 90; high stage 1 from 130 or
/// 80; elevated from 120 systolic; normal otherwise. Both high stages use
/// the high colors. Roughly the adult categories used by heart
/// associations; a guide, not a diagnosis.
BloodPressureStatus bloodPressureStatus(int systolic, int diastolic) {
  if (systolic < 90 || diastolic < 60) {
    return (label: 'Low', colors: VitalStatus.low);
  }
  if (systolic >= 140 || diastolic >= 90) {
    return (label: 'High · stage 2', colors: VitalStatus.high);
  }
  if (systolic >= 130 || diastolic >= 80) {
    return (label: 'High · stage 1', colors: VitalStatus.high);
  }
  if (systolic >= 120) {
    return (label: 'Elevated', colors: VitalStatus.elevated);
  }
  return (label: 'Normal', colors: VitalStatus.normal);
}
