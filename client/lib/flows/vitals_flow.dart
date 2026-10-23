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

import '../catalog/blood_pressure_input/blood_pressure_input.dart';
import '../catalog/blood_sugar_input/blood_sugar_input.dart';
import '../catalog/heart_rate_input/heart_rate_input.dart';
import '../catalog/icon_badge/icon_badge.dart';
import '../catalog/temperature_input/temperature_input.dart';
import '../core/utils/text_format.dart';
import '../models/tracking_flow.dart';

/// The message sent to the agent to start the vitals flow.
const String startVitalsFlowMessage =
    'I want to log my vitals in the Vitals tracker.';

/// Vitals: Readings (blood pressure, heart rate, temperature, blood sugar,
/// measurement time) → Save, then a summary.
///
/// Uses the four vital input components from `lib/catalog/` (one folder per input) plus
/// [iconBadge]. The "vitalsEntered" action saves an entry like
/// "BP 120/80 mmHg · 72 bpm · 36.6 °C · blood sugar 95 mg/dL".
final TrackingFlow vitalsFlow = TrackingFlow(
  name: 'vitals',
  startMessage: startVitalsFlowMessage,
  loadingLabel: 'Preparing your vitals log…',
  customItems: [
    iconBadge,
    bloodPressureInput,
    heartRateInput,
    temperatureInput,
    bloodSugarInput,
  ],
  saveAction: 'vitalsEntered',
  category: 'Vitals',
  icon: 'heartPulse',
  // Readings the screen did not send are left out.
  describe: (a) => joinParts([
    if (a['systolic'] != null && a['diastolic'] != null)
      'BP ${asText(a['systolic'])}/${asText(a['diastolic'])} mmHg',
    if (a['heartRate'] != null) '${asText(a['heartRate'])} bpm',
    if (a['temperature'] != null) '${asText(a['temperature'])} °C',
    if (a['bloodSugar'] != null) 'blood sugar ${asText(a['bloodSugar'])} mg/dL',
    if (a['measuredAt'] != null) 'at ${formatDateTime(a['measuredAt'])}',
  ]),
);
