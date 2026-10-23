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

/// The dark green, full-width button of the dashboard's "Generate summary",
/// with a spinner while [busy].
class PrimaryButton extends StatelessWidget {
  /// Creates the button.
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  /// The button's text.
  final String label;

  /// Called on tap; `null` turns the button off.
  final VoidCallback? onPressed;

  /// An optional icon before [label].
  final IconData? icon;

  /// Whether to show a spinner instead of [label].
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final Widget child = busy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onPrimary,
            ),
          )
        : Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          );
    return FilledButton(
      onPressed: busy ? () {} : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.border,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: icon == null || busy
          ? child
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(icon, size: 20), const SizedBox(width: 8), child],
            ),
    );
  }
}
