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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../../models/body_map/body_map.dart';
import '../../../models/body_map/ranked_region.dart';

/// The figure's own CustomPaint, for tests.
///
/// Tests find the figure with this key and tap at a point inside it to
/// select a region.
const Key bodyFigureKey = ValueKey<String>('body-figure');

/// The figure: one painter, one hit test, however many regions.
///
/// Instead of one widget per region, a single [CustomPaint] draws all of
/// them, and a tap is matched to a region by checking which outline holds
/// the tap point.
class BodyFigure extends StatelessWidget {
  /// Creates the figure.
  const BodyFigure({
    super.key,
    required this.view,
    required this.size,
    required this.ordered,
    required this.selected,
    required this.onTap,
    required this.skin,
    required this.mark,
  });

  /// The side to draw.
  final BodyView view;

  /// Size of the drawing. Its height is always the width times
  /// [kBodyAspect], so the traced paths line up with it.
  final Size size;

  /// Every tappable region in screen reader order (see [rankRegions]).
  final List<RankedRegion> ordered;

  /// Canonical names currently chosen.
  final Set<String> selected;

  /// Called with the region the user tapped, on the figure or through a
  /// screen reader.
  final ValueChanged<BodyRegion> onTap;

  /// Color of the body.
  final Color skin;

  /// Color of chosen regions.
  final Color mark;

  /// Topmost region under [point], or null for a gap between parts.
  BodyRegion? _hit(Offset point) {
    final List<BodyRegion> here = regionsFor(view);
    // Walk backwards: regions later in the list are painted on top, so the
    // first match from the end is the one the user can see. Each clipper
    // builds its path at [size], so it is in the same coordinates as the tap.
    for (int i = here.length - 1; i >= 0; i--) {
      final BodyRegion r = here[i];
      if (r.decorative) continue;
      if (r.clipper.getClip(size).contains(point)) return r;
    }
    return null;
  }

  /// Wraps the painter in a tap detector that turns a tap point into a
  /// region with [_hit]. Taps between parts do nothing.
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final BodyRegion? region = _hit(details.localPosition);
        if (region != null) onTap(region);
      },
      child: CustomPaint(
        key: bodyFigureKey,
        size: size,
        painter: _BodyPainter(
          view: view,
          ordered: ordered,
          selected: selected,
          onTap: onTap,
          textDirection: Directionality.of(context),
          skin: skin,
          mark: mark,
          separator: scheme.surface,
          detail: scheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

/// Paints every region of one side of the body, and gives each tappable
/// region its own node for screen readers.
class _BodyPainter extends CustomPainter {
  /// Creates the painter and works out [selectedIds] from [selected].
  _BodyPainter({
    required this.view,
    required this.ordered,
    required this.selected,
    required this.onTap,
    required this.textDirection,
    required this.skin,
    required this.mark,
    required this.separator,
    required this.detail,
  }) : selectedIds = <String>{
         for (final RankedRegion r in ordered)
           if (r.region.view == view && selected.contains(r.region.label))
             r.region.id,
       };

  /// The side to paint.
  final BodyView view;

  /// Every tappable region, in the order a screen reader visits them.
  final List<RankedRegion> ordered;

  /// Canonical names currently chosen, on both sides.
  final Set<String> selected;

  /// Called when a screen reader user activates a region.
  final ValueChanged<BodyRegion> onTap;

  /// The painter has no context to read a direction from.
  final TextDirection textDirection;

  /// Ids of the chosen regions on this side only. The selection is stored by
  /// name, but painting goes by id, so the names are turned into ids once
  /// here instead of on every paint.
  final Set<String> selectedIds;

  /// Every region is live, so every region is drawn the same: anything
  /// dimmed would read as "you may not report pain there".
  final Color skin;

  /// Selected regions.
  final Color mark;

  /// The seams between parts and the stems out to the finger/toe selectors.
  final Color separator;

  /// The finger/toe selectors, drawn as rings so they read as controls.
  final Color detail;

  /// Draws the regions in list order, so later ones cover earlier ones.
  @override
  void paint(Canvas canvas, Size size) {
    final List<BodyRegion> here = regionsFor(view);
    final fill = Paint()..style = PaintingStyle.fill;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Three kinds of region: decorative shapes (skin, or seam lines in the
    // separator color), small ring selectors for fingers / toes / soles
    // (an outline, filled only when chosen), and normal body parts.
    for (final r in here) {
      final Path path = r.clipper.getClip(size);
      if (r.decorative) {
        canvas.drawPath(path, fill..color = r.tracery ? separator : skin);
      } else if (r.ring) {
        if (selectedIds.contains(r.id)) {
          canvas.drawPath(path, fill..color = mark);
        }
        canvas.drawPath(path, edge..color = detail);
      } else {
        canvas.drawPath(
          path,
          fill..color = selectedIds.contains(r.id) ? mark : skin,
        );
      }
    }
  }

  /// One node per region, in the agent's order, so a screen reader reaches
  /// every part of the body without a visible list.
  @override
  SemanticsBuilderCallback get semanticsBuilder => (Size size) {
    return <CustomPainterSemantics>[
      for (final RankedRegion r in ordered)
        if (r.region.view == view)
          CustomPainterSemantics(
            rect: r.region.clipper.getClip(size).getBounds(),
            properties: SemanticsProperties(
              label: r.display,
              textDirection: textDirection,
              button: true,
              selected: selected.contains(r.region.label),
              onTap: () => onTap(r.region),
            ),
          ),
    ];
  };

  /// Repaints only when something that changes the pixels has changed.
  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.view != view ||
      !setEquals(old.selectedIds, selectedIds) ||
      old.skin != skin ||
      old.mark != mark ||
      old.separator != separator ||
      old.detail != detail;

  /// Rebuilds the screen reader nodes when the side, the selection, the
  /// order or wording of regions, or the text direction changes.
  ///
  /// [onTap] is left out: a new callback does the same thing, since it reads
  /// the picker's current state when called.
  @override
  bool shouldRebuildSemantics(_BodyPainter old) =>
      old.view != view ||
      !setEquals(old.selected, selected) ||
      !identical(old.ordered, ordered) ||
      old.textDirection != textDirection;
}
