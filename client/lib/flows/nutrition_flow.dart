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

import 'package:genui/genui.dart';

import '../catalog/icon_badge/icon_badge.dart';
import '../core/utils/text_format.dart';
import '../models/tracking_flow.dart';

/// The message sent to the agent to start the nutrition flow.
const String startNutritionFlowMessage =
    'I want to log a meal in the Food / Nutrition tracker.';

/// Custom components for the nutrition flow, on top of genui's built-in ones.
///
/// To add one, create a [CatalogItem] (name, JSON schema, widget builder) and
/// list it here; screens can then use it by name.
final List<CatalogItem> nutritionCustomItems = [iconBadge];

/// Food / Nutrition: Meal type → Food items → Quantity → Meal time → Notes →
/// Save, then a summary.
///
/// The "saveNutritionEntry" action saves an entry like
/// "Lunch · Rice (1 bowl), Dal (1 cup) · Today · 1:00 PM". When the user
/// gave no quantities, the plain food item list is used instead.
final TrackingFlow nutritionFlow = TrackingFlow(
  name: 'nutrition',
  startMessage: startNutritionFlowMessage,
  loadingLabel: 'Preparing your meal log…',
  customItems: nutritionCustomItems,
  saveAction: 'saveNutritionEntry',
  category: 'Food & nutrition',
  icon: 'restaurant',
  describe: (a) => joinParts([
    asText(a['mealType']),
    // Rows of {"item": "Rice", "amount": "1 bowl"}.
    if (a['quantities'] case final List<Object?> rows)
      rows
          .map(
            (row) => row is Map
                ? '${asText(row['item'])} (${asText(row['amount'])})'
                : asText(row),
          )
          .join(', ')
    else
      asText(a['foodItems']),
    joinParts([asText(a['mealDay']), formatTimeOfDay(a['mealTime'])]),
  ]),
);

/// genui's basic catalog plus [nutritionCustomItems].
///
/// A shortcut for [TrackingFlow.catalog] of [nutritionFlow].
Catalog get nutritionCatalog => nutritionFlow.catalog;
