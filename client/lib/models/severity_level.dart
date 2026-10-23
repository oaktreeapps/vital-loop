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

import 'package:flutter/painting.dart';

import '../core/theme/app_colors.dart';

// The rules behind SeverityInput: the 1–10 scale, its four bands and what
// each number means.

/// The lowest severity.
const int minSeverity = 1;

/// The highest severity.
const int maxSeverity = 10;

/// The severity shown before the user picks one.
const int defaultSeverity = 5;

/// What each severity means, from 1 (index 0) to 10.
const List<String> _descriptions = [
  'Barely noticeable',
  'Noticeable but mild',
  'Mild, distracting at times',
  'Uncomfortable',
  'Gets in the way of some things',
  'Hard to ignore',
  'Dominates your focus',
  'Hard to do anything',
  'Unable to do anything',
  'Worst imaginable',
];

/// [severity] kept between [minSeverity] and [maxSeverity].
int clampSeverity(num severity) =>
    severity.round().clamp(minSeverity, maxSeverity);

/// What [severity] means for daily life, e.g. "Hard to ignore" for 6.
String severityDescription(int severity) =>
    _descriptions[clampSeverity(severity) - 1];

/// The four bands of the 1–10 scale, each with a name and colors.
enum SeverityLevel {
  /// 1 to 3.
  mild('Mild', AppColors.green, AppColors.greenTint),

  /// 4 to 6.
  moderate('Moderate', AppColors.amber, AppColors.amberTint),

  /// 7 to 9.
  severe('Severe', AppColors.red, AppColors.redTint),

  /// 10.
  worst('Worst', AppColors.wine, AppColors.wineTint);

  /// Sets the band's name and colors.
  const SeverityLevel(this.label, this.color, this.background);

  /// The band's name, shown in the chip, e.g. "Moderate".
  final String label;

  /// The band's strong color: the face, the chip text, the filled
  /// segments and the thumb.
  final Color color;

  /// A light tint of [color], behind the face and the chip.
  final Color background;

  /// The band [severity] falls into: 1–3 [mild], 4–6 [moderate], 7–9
  /// [severe], 10 [worst].
  static SeverityLevel of(int severity) {
    if (severity <= 3) return mild;
    if (severity <= 6) return moderate;
    if (severity <= 9) return severe;
    return worst;
  }
}
