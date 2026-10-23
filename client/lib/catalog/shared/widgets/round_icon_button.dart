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

/// A round button with an icon, 40px unless [size] says otherwise, e.g. the
/// − and + of a reading.
///
/// Off-white with a thin border; beige while pressed; grayed out when
/// [onPressed] is null.
class RoundIconButton extends StatelessWidget {
  /// Creates the button showing [icon], read out as [tooltip].
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 40,
  });

  /// The button's width and height.
  final double size;

  /// The icon in the middle.
  final IconData icon;

  /// The text shown on long press and read by screen readers.
  final String tooltip;

  /// Called on tap; `null` turns the button off.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.square(size)),
        minimumSize: WidgetStatePropertyAll(Size.square(size)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: const WidgetStatePropertyAll(CircleBorder()),
        side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? AppColors.border
              : AppColors.field,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? AppColors.tick
              : AppColors.primary,
        ),
      ),
    );
  }
}
