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

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/painting.dart';

import '../catalog/shared/catalog_item.dart';
import '../catalog/vitalloop_catalog.dart';
import '../core/theme/app_colors.dart';

import '../core/utils/text_format.dart';
import 'health_log.dart';

/// A guided tracking flow, such as logging a meal or a medication dose.
///
/// Its screens and the LLM's instructions live on the backend, in
/// `server/flows/<name>/`; the backend serves the flow at
/// `<backend>/<name>`. Every flow renders with the basic components plus
/// [customItems].
class TrackingFlow {
  /// Creates a flow. Only [name], [startMessage] and [loadingLabel] are
  /// required; the rest have defaults for a flow that saves nothing.
  TrackingFlow({
    required this.name,
    required this.startMessage,
    required this.loadingLabel,
    this.customItems = const [],
    this.saveAction,
    this.category = '',
    this.icon = 'check',
    this.iconColor = AppColors.primary,
    this.describe,
    this.notesKey = 'notes',
  });

  /// The flow's folder in `server/flows/` and its path on the backend,
  /// e.g. "nutrition".
  final String name;

  /// The request that starts the flow.
  final String startMessage;

  /// Shown until the first screen arrives.
  final String loadingLabel;

  /// Components the screens may use on top of the basic ones.
  final List<CatalogItem> customItems;

  /// The UI action that saves an entry, e.g. "savePainEntry"; `null` for a
  /// flow that saves nothing.
  final String? saveAction;

  /// What an entry is, for the daily log and summary, e.g. "Pain".
  final String category;

  /// An IconBadge icon name for [category].
  final String icon;

  /// The color of [icon] in the daily summary.
  final Color iconColor;

  /// The flow's answers as one readable line.
  ///
  /// Used as [HealthLogEntry.details]. When `null`, every answer is joined
  /// into one line instead.
  final String Function(Map<String, Object?> answers)? describe;

  /// The answer holding the user's own notes, shown apart from [describe].
  final String notesKey;

  /// The log entry for [answers] if [action] saves one, else `null`.
  HealthLogEntry? entryFor(String action, Map<String, Object?> answers) {
    if (action != saveAction) return null;
    final String notes = asText(answers[notesKey]).trim();
    return HealthLogEntry(
      flowName: name,
      category: category,
      icon: icon,
      iconColor: iconColor,
      details: describe?.call(answers) ?? asText(answers.values.toList()),
      notes: notes.isEmpty ? null : notes,
      loggedAt: DateTime.now(),
      values: Map.unmodifiable(answers),
    );
  }

  /// VitalLoop's A2UI v1.0 catalog with the basic components plus
  /// [customItems].
  ///
  /// Every flow's catalog has the same id ([vitalLoopCatalogId]), the one the
  /// backend puts in each `createSurface`.
  late final CatalogImplementation catalog = vitalLoopCatalog(
    customItems: customItems,
  );
}
