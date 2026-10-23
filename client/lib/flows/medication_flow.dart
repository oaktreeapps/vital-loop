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

import '../catalog/icon_badge/icon_badge.dart';
import '../core/utils/text_format.dart';
import '../models/tracking_flow.dart';

/// The message sent to the agent to start the medication flow.
const String startMedicationFlowMessage =
    'I want to log a medication in the Medication tracker.';

/// Medication: Medicine name → Dose & schedule → Notes → Save, then a
/// summary.
///
/// Uses genui's basic components plus [iconBadge]. The
/// "saveMedicationEntry" action saves an entry like
/// "Paracetamol · 2 tablets · 26 Sep, 1:33 PM".
final TrackingFlow medicationFlow = TrackingFlow(
  name: 'medication',
  startMessage: startMedicationFlowMessage,
  loadingLabel: 'Preparing your medication log…',
  customItems: [iconBadge],
  saveAction: 'saveMedicationEntry',
  category: 'Medication',
  icon: 'medication',
  describe: (a) => joinParts([
    asText(a['medicineName']),
    if (a['dosage'] case final num dose)
      '${asText(dose)} ${dose == 1 ? 'tablet' : 'tablets'}',
    if (a['scheduledAt'] != null) formatDateTime(a['scheduledAt']),
  ]),
);
