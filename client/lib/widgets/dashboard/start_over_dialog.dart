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
import '../common/app_dialog.dart';
import '../common/primary_button.dart';

/// Asks before clearing today's log: "Start over" clears it, "Keep my
/// entries" or tapping outside keeps it.
///
/// Closes with `true` to clear the log, else `false` or `null`. Shown by the
/// dashboard's start over button.
class StartOverDialog extends StatelessWidget {
  /// Creates the dialog for a log of [entryCount] entries.
  const StartOverDialog({super.key, required this.entryCount});

  /// How many entries the log has, to say what will be cleared.
  final int entryCount;

  @override
  Widget build(BuildContext context) {
    final entries = entryCount == 1 ? '1 entry' : '$entryCount entries';
    return AppDialog(
      icon: Icons.restart_alt_rounded,
      warning: true,
      eyebrow: 'Start over',
      title: 'Clear today’s log?',
      body:
          'This removes the $entries you logged today, so you can start '
          'again. It can’t be undone.',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          PrimaryButton(
            label: 'Start over',
            icon: Icons.restart_alt_rounded,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              'Keep my entries',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      children: const [],
    );
  }
}
