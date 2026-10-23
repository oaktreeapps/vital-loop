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

// Tests for blood sugar: the status zones, and showing and stepping the
// value in mg/dL or mmol/L.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/vitals/blood_sugar.dart';
import 'package:vitalloop/models/vitals/vital_status.dart';

void main() {
  test('status follows the zones', () {
    expect(glucoseStatus(40), VitalStatus.low);
    expect(glucoseStatus(69), VitalStatus.low);
    expect(glucoseStatus(70), VitalStatus.normal);
    expect(glucoseStatus(98), VitalStatus.normal);
    expect(glucoseStatus(140), VitalStatus.normal);
    expect(glucoseStatus(160), VitalStatus.elevated);
    expect(glucoseStatus(199), VitalStatus.elevated);
    expect(glucoseStatus(200), VitalStatus.high);
    expect(glucoseStatus(220), VitalStatus.high);
  });

  test('mmol/L is shown from the stored mg/dL', () {
    expect(GlucoseUnit.mmolL.format(98), '5.4');
    expect(glucoseZoneLimits.map(GlucoseUnit.mmolL.format), [
      '3.9',
      '7.8',
      '11.1',
    ]);
    expect(GlucoseUnit.mgDl.format(98), '98');
  });

  test('every mmol/L step changes the shown value by exactly 0.1', () {
    double valueMgDl = minGlucoseMgDl;
    while (valueMgDl < maxGlucoseMgDl) {
      final double next = stepGlucose(valueMgDl, GlucoseUnit.mmolL, 1);
      final double shown = double.parse(GlucoseUnit.mmolL.format(valueMgDl));
      final double shownNext = double.parse(GlucoseUnit.mmolL.format(next));
      expect(next, next.roundToDouble(), reason: 'whole mg/dL');
      expect(
        (shownNext - shown).toStringAsFixed(1),
        '0.1',
        reason: 'from $valueMgDl mg/dL',
      );
      valueMgDl = next;
    }
  });
}
