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

import 'package:flutter/material.dart';

/// Every color the app uses, in one place.
///
/// They match the palette of the screens' JSON themes in `server/flows/`, so
/// the screens built in Dart and the ones Gemini builds look the same. No
/// other file should write a color value; use these names instead.
abstract final class AppColors {
  // Page and surfaces.

  /// Warm off-white page and dialog background.
  static const Color background = Color(0xFFF4F0EA);

  /// White fill of cards, text fields and thumbs.
  static const Color surface = Color(0xFFFFFFFF);

  /// Off-white fill of inputs, toggles and the thermometer tube.
  static const Color field = Color(0xFFFAF7F2);

  /// Light beige for borders and disabled buttons.
  static const Color border = Color(0xFFE8E1D6);

  /// Beige fill of round icon buttons and icon tiles.
  static const Color chevronFill = Color(0xFFEFEAE1);

  // Text.

  /// Dark green-gray for titles and icons.
  static const Color text = Color(0xFF1F2A24);

  /// Gray for secondary text, such as card subtitles.
  static const Color textMuted = Color(0xFF5C5B55);

  /// Lighter gray for small captions, such as scale labels.
  static const Color caption = Color(0xFF6B6A63);

  /// Brown for small upper-case labels above titles.
  static const Color eyebrow = Color(0xFF8A5A2B);

  // Brand.

  /// Dark green of the main buttons; also the Material theme's seed.
  static const Color primary = Color(0xFF2C4A3E);

  /// Text and icons on [primary], e.g. on the main buttons.
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Status colors: a strong color and a light tint of it. Vital signs,
  // severity bands and the dashboard's options all use these.

  /// Green: normal, mild, done.
  static const Color green = Color(0xFF3E6B4A);

  /// Light tint of [green].
  static const Color greenTint = Color(0xFFDFEBDF);

  /// Amber: elevated, moderate.
  static const Color amber = Color(0xFF8A6420);

  /// Light tint of [amber].
  static const Color amberTint = Color(0xFFF5ECD2);

  /// Red: high, severe.
  static const Color red = Color(0xFFA14B3F);

  /// Light tint of [red].
  static const Color redTint = Color(0xFFF4E3DD);

  /// Indigo: low.
  static const Color indigo = Color(0xFF3F4A8A);

  /// Light tint of [indigo].
  static const Color indigoTint = Color(0xFFE4E5F3);

  /// Rose: the vitals and blood pressure icons.
  static const Color rose = Color(0xFFA23E5A);

  /// Light tint of [rose].
  static const Color roseTint = Color(0xFFF3DFE4);

  /// Wine: the worst severity.
  static const Color wine = Color(0xFF8E2F3F);

  /// Light tint of [wine].
  static const Color wineTint = Color(0xFFF3DFE4);

  /// Marks something done, e.g. an option logged today.
  static const Color logged = green;

  /// Light background behind [logged] text.
  static const Color loggedTint = greenTint;

  /// Warm red for errors.
  static const Color error = Color(0xFFA4483A);

  /// Light red background behind [error] icons.
  static const Color errorTint = Color(0xFFF6E3DE);

  // Scales, rulers and segments.

  /// Light gray-beige for scale ticks.
  static const Color tick = Color(0xFFC9C2B6);

  /// Dark gray for a ruler's labelled (major) ticks.
  static const Color rulerMajorTick = Color(0xFF8A8780);

  /// Pale gray for a ruler's small (minor) ticks.
  static const Color rulerMinorTick = Color(0xFFD5CFC4);

  /// Light beige of a scale's empty segments.
  static const Color inactiveSegment = Color(0xFFEFEAE2);

  /// Gray of a scale's numbers that aren't picked.
  static const Color inactiveText = rulerMajorTick;

  // Body map.

  /// The body map figure: a soft sage.
  static const Color bodySkin = Color(0xFFD5E1D8);

  /// A chosen area on the body map: a warm red that reads as "hurts here".
  static const Color bodySelected = Color(0xFFC8553D);

  // Care places.

  /// The star of a place's Google rating.
  static const Color starGold = Color(0xFFB8860B);

  // Care map.

  /// A pin on the care map.
  static const Color mapPin = green;

  /// The pin of the place picked on the care map or in its list.
  static const Color mapPinSelected = red;
}
