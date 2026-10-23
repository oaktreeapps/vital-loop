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

// Tests for body temperature: the status ranges and showing °C as °F.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/vitals/temperature.dart';
import 'package:vitalloop/models/vitals/vital_status.dart';

void main() {
  test('status follows the ranges', () {
    expect(temperatureStatus(34.5), VitalStatus.low);
    expect(temperatureStatus(35.0), VitalStatus.normal);
    expect(temperatureStatus(36.6), VitalStatus.normal);
    expect(temperatureStatus(37.5), VitalStatus.normal);
    expect(temperatureStatus(37.8), VitalStatus.elevated);
    expect(temperatureStatus(38.0), VitalStatus.elevated);
    expect(temperatureStatus(38.5), VitalStatus.high);
    expect(temperatureStatusLabel(VitalStatus.high), 'Fever');
  });

  test('°F is shown from the stored °C', () {
    expect(TempUnit.fahrenheit.fromCelsius(36.6).toStringAsFixed(1), '97.9');
    expect(TempUnit.fahrenheit.fromCelsius(minTempC).round(), 93);
    expect(TempUnit.fahrenheit.fromCelsius(maxTempC).round(), 108);
    expect(TempUnit.celsius.fromCelsius(36.6), 36.6);
  });
}
