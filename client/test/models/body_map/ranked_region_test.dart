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

// Tests for ordering the body map's regions: the agent's suggestions first,
// then every other region, so each one can always be picked.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/body_map/body_map.dart';
import 'package:vitalloop/models/body_map/ranked_region.dart';

void main() {
  test('no suggestions: every tappable region, none suggested', () {
    final List<RankedRegion> ranked = rankRegions(null);
    expect(ranked, hasLength(selectableRegions.length));
    expect(ranked.any((r) => r.suggested), isFalse);
    expect(ranked.any((r) => r.region.decorative), isFalse);
  });

  test("suggestions come first, with the agent's wording", () {
    final List<RankedRegion> ranked = rankRegions([
      {'id': 'front.throat'},
      {'id': 'front.forehead', 'label': ' Your forehead '},
    ]);
    expect(ranked[0].region.id, 'front.throat');
    expect(ranked[0].display, 'Throat');
    expect(ranked[0].suggested, isTrue);
    expect(ranked[1].display, 'Your forehead');
    expect(ranked[2].suggested, isFalse);
  });

  test('unknown, repeated and malformed suggestions are ignored', () {
    final List<RankedRegion> ranked = rankRegions([
      {'id': 'front.throat'},
      {'id': 'front.throat'},
      {'id': 'front.tail'},
      {'id': 'front._untappablefingers'},
      'front.forehead',
    ]);
    expect(ranked.where((r) => r.suggested), hasLength(1));
    expect(ranked, hasLength(selectableRegions.length));
    final List<String> ids = [for (final r in ranked) r.region.id];
    expect(ids.toSet(), hasLength(ids.length));
  });
}
