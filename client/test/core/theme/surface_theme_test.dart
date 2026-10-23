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

// Tests for surfaceThemeData: how the JSON theme of a surface becomes a
// Flutter ThemeData.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalloop/core/theme/surface_theme.dart';

import '../../support/test_utils.dart';

void main() {
  // The shared theme that every flow's screens use.
  late Map<String, Object?> json;
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    json =
        jsonDecode(File('$serverFlowsDir/shared/theme.json').readAsStringSync())
            as Map<String, Object?>;
  });

  test('a light JSON theme stays light on a phone in dark mode', () {
    final dark = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
    final ThemeData theme = surfaceThemeData(dark, json);

    expect(theme.colorScheme.brightness, Brightness.light);
    expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
    expect(theme.colorScheme.onSurface, const Color(0xFF1F2A24));
    // The date and time pickers draw on the white surface, not a dark one.
    expect(theme.datePickerTheme.backgroundColor, const Color(0xFFFFFFFF));
    expect(theme.timePickerTheme.backgroundColor, const Color(0xFFFFFFFF));
    expect(
      theme.datePickerTheme.headerBackgroundColor,
      const Color(0xFF2C4A3E),
    );
  });

  test('"brightness" in the JSON wins over the background color', () {
    final ThemeData theme = surfaceThemeData(ThemeData(), {
      ...json,
      'brightness': 'dark',
    });
    expect(theme.colorScheme.brightness, Brightness.dark);
  });
}
