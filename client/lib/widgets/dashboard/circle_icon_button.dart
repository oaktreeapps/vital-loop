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

import '../../core/theme/app_colors.dart';

/// A round beige icon button, matching the cards' chevrons.
///
/// An [IconButton], so it has a 48dp tap target, a tooltip and a label for
/// screen readers.
class CircleIconButton extends StatelessWidget {
  /// Creates the button.
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  /// The icon in the middle of the circle.
  final IconData icon;

  /// The text shown on long press, also read by screen readers.
  final String tooltip;

  /// Called when the button is tapped; `null` turns the button off.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.text,
        backgroundColor: AppColors.chevronFill,
        disabledForegroundColor: AppColors.tick,
        disabledBackgroundColor: AppColors.chevronFill,
        fixedSize: const Size.square(40),
      ),
    );
  }
}
