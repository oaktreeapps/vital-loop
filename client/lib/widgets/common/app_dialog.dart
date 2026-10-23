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

/// The frame of the app's own dialogs (the setup dialogs and the city
/// dialog), in the dashboard's style: an icon tile, a small upper-case
/// [eyebrow], a serif [title], the [body] text, [children] and one
/// full-width [action] button.
class AppDialog extends StatelessWidget {
  /// Creates the dialog frame.
  const AppDialog({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.children,
    required this.action,
    this.warning = false,
  });

  /// The icon in the tile at the top.
  final IconData icon;

  /// Whether something is wrong, which tints the icon tile red.
  final bool warning;

  /// The small upper-case label above [title].
  final String eyebrow;

  /// The dialog's title.
  final String title;

  /// One or two sentences under [title].
  final String body;

  /// The dialog's content between [body] and [action].
  final List<Widget> children;

  /// The main button at the bottom.
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        // Readable on wide screens (web, tablets).
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: warning ? AppColors.errorTint : AppColors.loggedTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: warning ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                eyebrow.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.eyebrow,
                ),
              ),
              const SizedBox(height: 6),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: GoogleFonts.fraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              ...children,
              const SizedBox(height: 24),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
