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

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:logging/logging.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/surface_theme.dart';
import '../core/utils/text_format.dart';

/// Logger for this file; writes a line every time an entry is saved.
final Logger _log = Logger('HealthLog');

/// One saved entry from a tracking flow, e.g. a pain log.
///
/// `TrackingFlow.entryFor` builds it when the user saves a flow. The
/// dashboard shows it as a badge, and the daily summary and the PDF report
/// read it later.
@immutable
class HealthLogEntry {
  /// Creates an entry. [notes] and [values] are optional.
  const HealthLogEntry({
    required this.flowName,
    required this.category,
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.details,
    required this.loggedAt,
    this.notes,
    this.values = const {},
  });

  /// The flow that saved it, e.g. "pain".
  final String flowName;

  /// What was logged, e.g. "Pain".
  final String category;

  /// An IconBadge icon name for the category.
  final String icon;

  /// The color of [icon], e.g. in the daily summary's list of entries.
  final Color iconColor;

  /// The entry in one readable line.
  final String details;

  /// The user's own notes or description, if any.
  final String? notes;

  /// When the user saved the entry.
  final DateTime loggedAt;

  /// Every answer the flow collected, for the agent.
  final Map<String, Object?> values;

  /// The entry as the daily summary sends it to the agent.
  Map<String, Object?> toJson() => {
    'category': category,
    'icon': icon,
    'color': formatHexColor(iconColor),
    'line': details,
    if (notes != null) 'notes': notes,
    'time': formatTime(loggedAt),
    'values': values,
  };
}

/// Today's saved entries. In memory for now; a store or a backend comes later.
///
/// It is a [ChangeNotifier], so widgets that listen to it (like the
/// dashboard) rebuild when an entry is added or the log is cleared.
class HealthLog extends ChangeNotifier {
  /// The saved entries, oldest first.
  final List<HealthLogEntry> _entries = [];

  /// A read-only copy of the saved entries, oldest first.
  List<HealthLogEntry> get entries => List.unmodifiable(_entries);

  /// Whether nothing has been saved yet today.
  bool get isEmpty => _entries.isEmpty;

  /// How many entries [flowName] saved.
  int countFor(String flowName) =>
      _entries.where((e) => e.flowName == flowName).length;

  /// Saves [entry] and tells listeners about it.
  void add(HealthLogEntry entry) {
    _log.info('Saved ${entry.category}: ${entry.details}');
    _entries.add(entry);
    notifyListeners();
  }

  /// Removes every entry and tells listeners, e.g. to start a fresh day or
  /// to reset state between tests.
  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

/// The app's log of today's entries.
///
/// One shared instance used by every screen.
final HealthLog healthLog = HealthLog();
