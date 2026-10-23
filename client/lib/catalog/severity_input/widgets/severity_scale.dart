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
import '../../../models/severity_level.dart';

/// A 1–10 scale: ten segments that fill up to [severity] in each number's
/// band color, a round thumb with the number, and a row of numbers to tap.
///
/// Dragging sideways or tapping anywhere on it picks the number under the
/// finger. It only reports numbers through [onChanged]; the parent keeps
/// [severity]. Screen readers see a slider that steps 1 at a time.
class SeverityScale extends StatelessWidget {
  /// Creates the scale showing [severity].
  const SeverityScale({
    super.key,
    required this.severity,
    required this.onChanged,
  });

  /// The picked severity, from 1 to 10.
  final int severity;

  /// Called with the number the user points at or taps.
  final ValueChanged<int> onChanged;

  /// The scale's height: thumb, segments and numbers.
  static const double height = 92;

  /// The number under [dx] across a scale [width] wide.
  static int severityAt(double dx, double width) =>
      clampSeverity((dx / width * maxSeverity).ceil());

  @override
  Widget build(BuildContext context) {
    final SeverityLevel band = SeverityLevel.of(severity);
    final TextStyle base =
        Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    return Semantics(
      slider: true,
      label: 'Severity',
      value: '$severity of 10, ${severityDescription(severity)}',
      increasedValue: '${clampSeverity(severity + 1)} of 10',
      decreasedValue: '${clampSeverity(severity - 1)} of 10',
      onIncrease: severity < maxSeverity ? () => onChanged(severity + 1) : null,
      onDecrease: severity > minSeverity ? () => onChanged(severity - 1) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          // Horizontal drags only, so scrolling the screen over the scale
          // doesn't change it; a tap picks a number too.
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) =>
                onChanged(severityAt(details.localPosition.dx, width)),
            onHorizontalDragStart: (details) =>
                onChanged(severityAt(details.localPosition.dx, width)),
            onHorizontalDragUpdate: (details) =>
                onChanged(severityAt(details.localPosition.dx, width)),
            child: SizedBox(
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The ten segments, filled up to the picked number.
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    height: 16,
                    child: Row(
                      children: [
                        for (var i = minSeverity; i <= maxSeverity; i++) ...[
                          if (i > minSeverity) const SizedBox(width: 3),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: i <= severity
                                    ? SeverityLevel.of(i).color
                                    : AppColors.inactiveSegment,
                                borderRadius: _segmentRadius(i),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // The thumb, centered on the picked segment.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 80),
                    curve: Curves.easeOut,
                    left: (severity - 0.5) / maxSeverity * width - 20,
                    top: 8,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: band.color, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.text.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$severity',
                        style: base.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: band.color,
                        ),
                      ),
                    ),
                  ),
                  // The numbers 1 to 10, each a tap target.
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    height: 28,
                    child: ExcludeSemantics(
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          children: [
                            for (var i = minSeverity; i <= maxSeverity; i++)
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => onChanged(i),
                                  child: Center(
                                    child: Text(
                                      '$i',
                                      style: base.copyWith(
                                        fontSize: 12,
                                        fontWeight: i == severity
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: i == severity
                                            ? band.color
                                            : AppColors.inactiveText,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Segment [i]'s corners: the ends of the bar are fully round.
  static BorderRadius _segmentRadius(int i) {
    const small = Radius.circular(3);
    const round = Radius.circular(999);
    if (i == minSeverity) {
      return const BorderRadius.only(
        topLeft: round,
        bottomLeft: round,
        topRight: small,
        bottomRight: small,
      );
    }
    if (i == maxSeverity) {
      return const BorderRadius.only(
        topLeft: small,
        bottomLeft: small,
        topRight: round,
        bottomRight: round,
      );
    }
    return BorderRadius.circular(3);
  }
}
