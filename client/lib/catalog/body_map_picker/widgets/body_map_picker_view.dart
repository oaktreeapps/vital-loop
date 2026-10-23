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

import '../../../core/theme/app_colors.dart';
import '../../../models/body_map/body_map.dart';
import '../../../models/body_map/ranked_region.dart';
import 'body_figure.dart';
import 'body_view_toggle.dart';

/// The whole picker: the Front / Back switch, the figure and the chips for
/// the areas chosen so far.
///
/// The selection itself lives in the data model, not here. This widget gets
/// it in [selected] and reports every change through [onChanged].
class BodyMapPickerView extends StatefulWidget {
  /// Creates the picker.
  const BodyMapPickerView({
    super.key,
    required this.ordered,
    required this.selected,
    required this.onChanged,
    this.opensOn,
    this.maxSelections,
    this.skinColor,
    this.selectedColor,
  });

  /// Every tappable region, suggested ones first (see [rankRegions]).
  final List<RankedRegion> ordered;

  /// Canonical names of the areas chosen so far, e.g. `Left Knee`.
  final List<String> selected;

  /// Called with the new list of names whenever an area is added or removed.
  final ValueChanged<List<String>> onChanged;

  /// The side the backend asked to show first, or null to pick one from the
  /// suggestions.
  final BodyView? opensOn;

  /// The most areas that can be chosen at once (at least 1), or null for no
  /// limit.
  final int? maxSelections;

  /// Color for the body, or null for [AppColors.bodySkin].
  final Color? skinColor;

  /// Color for chosen areas, or null for [AppColors.bodySelected].
  final Color? selectedColor;

  @override
  State<BodyMapPickerView> createState() => _BodyMapPickerState();
}

/// Holds the only local state of the picker: which side is showing.
class _BodyMapPickerState extends State<BodyMapPickerView> {
  /// The side the user switched to, or null until they first use the switch.
  BodyView? _view;

  /// The side showing: the one the user switched to; until then the side
  /// the agent asked for, failing that the side holding most of its
  /// suggestions, so a back-pain step does not open on a chest.
  BodyView get _current => _view ?? widget.opensOn ?? _busierSide();

  /// The side with more suggested regions. Front wins a tie, including when
  /// there are no suggestions at all.
  BodyView _busierSide() {
    var front = 0;
    var back = 0;
    for (final RankedRegion r in widget.ordered) {
      if (!r.suggested) continue;
      r.region.view == BodyView.front ? front++ : back++;
    }
    return back > front ? BodyView.back : BodyView.front;
  }

  /// Adds [name] to the selection, or removes it if it is already there.
  ///
  /// When [BodyMapPickerView.maxSelections] is reached, a new tap is ignored.
  /// The one exception is a limit of 1: then the new area replaces the old
  /// one, so a single-choice picker works like radio buttons.
  void _toggle(String name) {
    final next = List<String>.of(widget.selected);
    if (next.remove(name)) {
      widget.onChanged(next);
      return;
    }
    final int? max = widget.maxSelections;
    if (max != null && next.length >= max) {
      if (max != 1) return;
      next.clear();
    }
    next.add(name);
    widget.onChanged(next);
  }

  /// Builds the switch, the figure sized to the available width, and below
  /// it either a hint or one chip per chosen area.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Set<String> selected = widget.selected.toSet();
    final Color skin = widget.skinColor ?? AppColors.bodySkin;
    final Color mark = widget.selectedColor ?? AppColors.bodySelected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: BodyViewToggle(
            current: _current,
            onChanged: (v) => setState(() => _view = v),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Tall on a phone, capped on a tablet.
            final double width = constraints.maxWidth.clamp(0, 340);
            return Center(
              child: BodyFigure(
                view: _current,
                size: Size(width, width * kBodyAspect),
                ordered: widget.ordered,
                selected: selected,
                onTap: (region) => _toggle(region.label),
                skin: skin,
                mark: mark,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (widget.selected.isEmpty)
          Text(
            'Nothing selected yet. Tap where it hurts.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          )
        else
          // The chosen areas, on both sides; tap one to remove it.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final String name in widget.selected)
                InputChip(
                  label: Text(name),
                  onDeleted: () => _toggle(name),
                  deleteButtonTooltipMessage: 'Remove $name',
                  side: BorderSide(color: mark.withValues(alpha: 0.4)),
                  backgroundColor: mark.withValues(alpha: 0.1),
                  deleteIconColor: mark,
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
