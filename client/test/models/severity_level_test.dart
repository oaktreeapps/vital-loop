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

// Tests for the 1–10 severity scale: its bands, their meaning, and keeping
// values on the scale.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/models/severity_level.dart';

void main() {
  test('bands follow the scale', () {
    for (final (int value, SeverityLevel band) in [
      (1, SeverityLevel.mild),
      (3, SeverityLevel.mild),
      (4, SeverityLevel.moderate),
      (6, SeverityLevel.moderate),
      (7, SeverityLevel.severe),
      (9, SeverityLevel.severe),
      (10, SeverityLevel.worst),
    ]) {
      expect(SeverityLevel.of(value), band, reason: '$value');
    }
    expect(severityDescription(1), 'Barely noticeable');
    expect(severityDescription(5), 'Gets in the way of some things');
    expect(severityDescription(10), 'Worst imaginable');
    expect(clampSeverity(0), minSeverity);
    expect(clampSeverity(15), maxSeverity);
    expect(clampSeverity(3.6), 4);
  });
}
