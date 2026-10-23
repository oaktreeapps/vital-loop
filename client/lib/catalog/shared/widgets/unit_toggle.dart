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

/// One choice in a [UnitToggle], e.g. °C.
class UnitOption<T> {
  /// Creates a choice for [value], shown as [label] and read out as
  /// [semanticLabel].
  const UnitOption(this.value, this.label, {required this.semanticLabel});

  /// The unit this choice selects.
  final T value;

  /// The text on the pill, e.g. "°C".
  final String label;

  /// What a screen reader says, e.g. "Celsius".
  final String semanticLabel;
}

/// A pill-shaped unit switch, e.g. °C / °F. The selected unit is dark green.
class UnitToggle<T> extends StatelessWidget {
  /// Creates the switch over [options], showing [selected].
  const UnitToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  /// The units to choose from, in order.
  final List<UnitOption<T>> options;

  /// The selected unit.
  final T selected;

  /// Called with the unit the user taps.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final UnitOption<T> option in options)
            Semantics(
              button: true,
              selected: option.value == selected,
              label: option.semanticLabel,
              onTap: () => onChanged(option.value),
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(option.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: option.value == selected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    option.label,
                    style: style?.copyWith(
                      color: option.value == selected
                          ? AppColors.onPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
