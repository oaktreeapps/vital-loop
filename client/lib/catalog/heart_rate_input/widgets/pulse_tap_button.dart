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

import '../../../core/theme/app_colors.dart';

/// The pill button the user taps along with their pulse.
///
/// Outlined in dark green; filled while the user is [counting], with the
/// number of [taps] so far.
class PulseTapButton extends StatelessWidget {
  /// Creates the button.
  const PulseTapButton({
    super.key,
    required this.counting,
    required this.taps,
    required this.onTap,
  });

  /// Whether the user is tapping right now.
  final bool counting;

  /// How many taps are in the current count.
  final int taps;

  /// Called on every tap.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = counting ? AppColors.onPrimary : AppColors.primary;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.touch_app_rounded, size: 18, color: foreground),
      label: Text(
        counting ? 'Keep tapping · $taps' : 'Tap with your pulse',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        backgroundColor: counting ? AppColors.primary : Colors.transparent,
        foregroundColor: foreground,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: const StadiumBorder(),
      ),
    );
  }
}
