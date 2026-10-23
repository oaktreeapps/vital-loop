// Copyright 2026 The Daily Health Tracker Authors.
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
//
// Modified by Oaktreeapps in 2026.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../catalog/shared/data_binding.dart';
import 'body_map.dart';

/// One region, with the wording to show for it and whether the agent put it
/// forward.
@immutable
class RankedRegion {
  /// Wraps [region] with the text to show for it.
  const RankedRegion(this.region, this.display, {this.suggested = false});

  /// The region of the figure this entry is about.
  final BodyRegion region;

  /// The agent's wording if it sent one, else the canonical name.
  final String display;

  /// True if the agent named it. Decides ordering only, never reachability.
  final bool suggested;
}

/// Every selectable region: the agent's ranking first, then the rest in
/// anatomical order, so nothing is ever unreachable. Unknown ids are ignored.
///
/// [raw] is the `suggested` list from the component JSON, or null.
List<RankedRegion> rankRegions(Object? raw) {
  final ranked = <RankedRegion>[];
  // Ids already added, so a suggestion sent twice is listed only once.
  final taken = <String>{};
  if (raw is List) {
    for (final Object? item in raw) {
      if (item is! Map) continue;
      final id = '${item['id'] ?? ''}';
      final BodyRegion? region = selectableRegions[id];
      if (region == null || !taken.add(id)) continue;
      final String? label = stringOrNull(item['label'])?.trim();
      ranked.add(
        RankedRegion(
          region,
          label == null || label.isEmpty ? region.label : label,
          suggested: true,
        ),
      );
    }
  }
  // Then every other tappable region, so the list is always complete.
  for (final BodyRegion r in bodyMap) {
    if (!r.decorative && !taken.contains(r.id)) {
      ranked.add(RankedRegion(r, r.label));
    }
  }
  return ranked;
}
