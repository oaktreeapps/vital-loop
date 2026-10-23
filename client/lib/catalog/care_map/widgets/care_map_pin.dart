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

/// A map pin for one place: green, or red and larger when [selected], with
/// the place's [name] above it when selected.
///
/// Its tip is at the bottom center, on the place's position.
class CareMapPin extends StatelessWidget {
  /// Creates the pin for the place called [name].
  const CareMapPin({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  /// The place's name, read by screen readers and shown when [selected].
  final String name;

  /// Whether this is the picked place.
  final bool selected;

  /// Called when the pin is tapped.
  final VoidCallback onTap;

  /// The pin's width and height, so the map can place it.
  static const Size size = Size(160, 72);

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.mapPinSelected : AppColors.mapPin;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (selected)
              Container(
                constraints: BoxConstraints(maxWidth: size.width),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Icon(
              Icons.location_on_rounded,
              size: selected ? 44 : 36,
              color: color,
              shadows: [
                Shadow(
                  color: AppColors.text.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
