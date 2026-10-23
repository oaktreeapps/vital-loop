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
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// The look of a text field in the app's own dialogs: white, rounded, with a
/// green outline while focused and a red one with [errorText].
InputDecoration appInputDecoration({
  required String hintText,
  String? errorText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) => InputDecoration(
  hintText: hintText,
  hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted),
  filled: true,
  fillColor: AppColors.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  enabledBorder: _border(AppColors.border),
  disabledBorder: _border(AppColors.border),
  focusedBorder: _border(AppColors.primary, width: 1.5),
  errorBorder: _border(AppColors.error),
  focusedErrorBorder: _border(AppColors.error, width: 1.5),
  errorText: errorText,
  errorMaxLines: 4,
  errorStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error),
  prefixIcon: prefixIcon,
  suffixIcon: suffixIcon,
);

/// The text style typed text has in [appInputDecoration] fields.
TextStyle appInputTextStyle() =>
    GoogleFonts.dmSans(fontSize: 15, color: AppColors.text);

/// A rounded text field border in [color].
OutlineInputBorder _border(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
