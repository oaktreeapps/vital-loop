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

/// The bottom bar: "Generate summary", enabled once something is logged.
class SummaryBar extends StatelessWidget {
  /// Creates the bar.
  const SummaryBar({
    super.key,
    required this.entryCount,
    required this.onPressed,
  });

  /// How many entries are in today's log. The button is disabled at 0.
  final int entryCount;

  /// Called when the user taps "Generate summary".
  final VoidCallback onPressed;

  /// Builds the button, with a hint above it while nothing is logged yet.
  @override
  Widget build(BuildContext context) {
    final bool enabled = entryCount > 0;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!enabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Log something to generate today\'s summary',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              FilledButton.icon(
                onPressed: enabled ? onPressed : null,
                icon: const Icon(Icons.summarize_outlined, size: 20),
                label: Text(
                  enabled
                      ? 'Generate summary · $entryCount '
                            '${entryCount == 1 ? 'entry' : 'entries'}'
                      : 'Generate summary',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.textMuted,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
