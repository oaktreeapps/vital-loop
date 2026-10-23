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

// The rules behind TemperatureInput: the range, the units and the status.
// The temperature is always stored in °C; °F is only for display.

/// The lowest temperature on the thermometer, in °C.
const double minTempC = 34;

/// The highest temperature on the thermometer, in °C.
const double maxTempC = 42;

/// The temperature shown before the user picks one, in °C.
const double defaultTempC = 36.6;

/// A unit the temperature can be shown in.
enum TempUnit {
  /// Degrees Celsius, the unit the temperature is stored in.
  celsius('°C'),

  /// Degrees Fahrenheit, for display only.
  fahrenheit('°F');

  /// Creates a unit shown as [symbol].
  const TempUnit(this.symbol);

  /// The unit's symbol, e.g. "°C".
  final String symbol;

  /// [tempC], a temperature in °C, in this unit.
  double fromCelsius(double tempC) =>
      this == celsius ? tempC : tempC * 9 / 5 + 32;
}

/// [tempC] rounded to 0.1 °C and kept between [minTempC] and [maxTempC].
double roundTempC(double tempC) =>
    ((tempC.clamp(minTempC, maxTempC) * 10).round() / 10).toDouble();

/// The status of a body temperature in °C: under 35 is low, up to 37.5 is
/// normal, up to 38.0 is elevated, and above is a fever (shown as high).
/// A general adult guide, not a diagnosis.
VitalStatus temperatureStatus(double tempC) {
  if (tempC < 35) return VitalStatus.low;
  if (tempC <= 37.5) return VitalStatus.normal;
  if (tempC <= 38.0) return VitalStatus.elevated;
  return VitalStatus.high;
}

/// The status chip's text for [status]: "Fever" for a high temperature, the
/// usual label (Low, Normal, Elevated) otherwise.
String temperatureStatusLabel(VitalStatus status) =>
    status == VitalStatus.high ? 'Fever' : status.label;
