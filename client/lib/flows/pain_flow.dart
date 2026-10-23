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

import '../catalog/body_map_picker/body_map_picker.dart';
import '../catalog/icon_badge/icon_badge.dart';
import '../catalog/severity_input/severity_input.dart';
import '../core/utils/text_format.dart';
import '../models/tracking_flow.dart';

/// The message sent to the agent to start the pain flow.
const String startPainFlowMessage = 'I want to log pain in the Pain tracker.';

/// Pain: Body area → Pain level & start time → Notes → Save, then a summary.
///
/// The backend builds each step's screen; this flow adds the two custom
/// components the pain screens need ([bodyMapPicker] for "where does it
/// hurt" and [severityInput] for the 1–10 pain level) on top of the basic
/// catalog, and saves an entry when the `savePainEntry` action fires.
final TrackingFlow painFlow = TrackingFlow(
  name: 'pain',
  startMessage: startPainFlowMessage,
  loadingLabel: 'Preparing your pain log…',
  customItems: [iconBadge, bodyMapPicker, severityInput],
  saveAction: 'savePainEntry',
  category: 'Pain',
  icon: 'body',
  // The one-line summary shown in the health log: the areas, the pain level
  // and when it started. Parts the user skipped are left out.
  describe: (a) => joinParts([
    asText(a['bodyAreas']),
    if (a['painLevel'] != null) 'pain ${asText(a['painLevel'])}/10',
    if (a['startedAt'] != null) 'since ${formatDateTime(a['startedAt'])}',
  ]),
);
