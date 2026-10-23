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

// Tests for heart rate: the status ranges, the time between beats, and
// counting the pulse from taps.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/vitals/heart_rate.dart';
import 'package:vitalloop/models/vitals/vital_status.dart';

/// [count] taps, [gap] apart, from a fixed start.
List<DateTime> _taps(int count, Duration gap) => [
  for (var i = 0; i < count; i++) DateTime(2026).add(gap * i),
];

void main() {
  test('status follows the ranges', () {
    expect(heartRateStatus(55), VitalStatus.low);
    expect(heartRateStatus(60), VitalStatus.normal);
    expect(heartRateStatus(72), VitalStatus.normal);
    expect(heartRateStatus(100), VitalStatus.normal);
    expect(heartRateStatus(110), VitalStatus.high);
  });

  test('the time between beats follows the heart rate', () {
    expect(beatPeriod(72).inMilliseconds, 833);
    expect(beatPeriod(60).inMilliseconds, 1000);
    expect(beatPeriod(120).inMilliseconds, 500);
  });

  test('4 taps 1 s apart give 60 bpm', () {
    expect(bpmFromTaps(_taps(4, const Duration(seconds: 1))), 60);
    expect(bpmFromTaps(_taps(1, const Duration(seconds: 1))), isNull);
    expect(bpmFromTaps(_taps(3, const Duration(milliseconds: 500))), 120);
  });

  test('taps keep the last 6, and a long pause starts over', () {
    var taps = <DateTime>[];
    for (final DateTime tap in _taps(8, const Duration(seconds: 1))) {
      taps = addPulseTap(taps, tap);
    }
    expect(taps, hasLength(maxPulseTaps));

    taps = addPulseTap(taps, taps.last.add(const Duration(seconds: 4)));
    expect(taps, hasLength(1));
  });
}
