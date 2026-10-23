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
import '../catalog/severity_input/severity_input.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/text_format.dart';
import '../models/tracking_flow.dart';

/// The message sent to the agent to start the symptoms flow.
const String startSymptomsFlowMessage =
    'I want to log my symptoms in the Symptoms tracker.';

/// Symptoms: Select symptoms → Description, severity & start time → Save,
/// then a summary.
///
/// The backend builds each step's screen; this flow adds [severityInput] (the
/// 1–10 severity scale) on top of the basic catalog, and saves an entry when
/// the `symptomDetailsEntered` action fires. The user's free text is stored
/// under `description` instead of the usual `notes`.
final TrackingFlow symptomsFlow = TrackingFlow(
  name: 'symptoms',
  startMessage: startSymptomsFlowMessage,
  loadingLabel: 'Preparing your symptoms log…',
  customItems: [iconBadge, severityInput],
  saveAction: 'symptomDetailsEntered',
  category: 'Symptoms',
  icon: 'sick',
  iconColor: AppColors.amber,
  notesKey: 'description',
  // The one-line summary shown in the health log: the symptoms, the severity
  // and when they started. Parts the user skipped are left out.
  describe: (a) => joinParts([
    asText(a['symptoms']),
    if (a['severity'] != null) 'severity ${asText(a['severity'])}/10',
    if (a['startedAt'] != null) 'since ${formatDateTime(a['startedAt'])}',
  ]),
);
