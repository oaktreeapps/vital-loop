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

// Tests for the blood pressure ranges: each reading's label and colors.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/vitals/blood_pressure.dart';
import 'package:vitalloop/models/vitals/vital_status.dart';

void main() {
  test('status follows the ranges', () {
    for (final (int sys, int dia, String label, VitalStatus colors) in [
      (118, 76, 'Normal', VitalStatus.normal),
      (125, 78, 'Elevated', VitalStatus.elevated),
      (132, 84, 'High · stage 1', VitalStatus.high),
      (145, 93, 'High · stage 2', VitalStatus.high),
      (85, 55, 'Low', VitalStatus.low),
      (118, 92, 'High · stage 2', VitalStatus.high),
    ]) {
      final BloodPressureStatus status = bloodPressureStatus(sys, dia);
      expect(status.label, label, reason: '$sys/$dia');
      expect(status.colors, colors, reason: '$sys/$dia');
    }
  });
}
