// Copyright 2026 The Daily Health Tracker Authors.
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
//
// Modified by Oaktreeapps in 2026.

import 'package:flutter/material.dart';
import '../../../models/body_map/body_map.dart';

/// Front / Back as one labelled control: the figure is symmetrical enough
/// that an unlabelled flip leaves people guessing. A pill of two segments,
/// sized by its labels, so a surface theme's button padding can't squeeze it.
class BodyViewToggle extends StatelessWidget {
  /// Creates the switch showing [current] as the chosen side.
  const BodyViewToggle({
    super.key,
    required this.current,
    required this.onChanged,
  });

  /// The side that is showing now; its segment is filled.
  final BodyView current;

  /// Called with the side the user tapped.
  final ValueChanged<BodyView> onChanged;

  /// Builds one rounded segment per [BodyView], each a button for screen
  /// readers too.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final BodyView view in BodyView.values)
            // The Semantics node replaces the segment's own, so it needs the
            // tap action itself.
            Semantics(
              button: true,
              selected: view == current,
              label: '${view.label} of the body',
              excludeSemantics: true,
              onTap: () => onChanged(view),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(view),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  // At least 48 high, the minimum size of a tap target.
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: ShapeDecoration(
                    color: view == current ? scheme.primary : null,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    view.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: view == current
                          ? scheme.onPrimary
                          : scheme.onSurface.withValues(alpha: 0.7),
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
