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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/vitals/blood_sugar.dart';
import '../../../models/vitals/vital_status.dart';

/// A band of blood sugar zones (low, normal, elevated, high) with a drop
/// marker the user drags (or taps) to set the value.
///
/// The zones' widths follow their share of the 40–300 mg/dL range. The
/// limits between them (70, 140, 200 mg/dL) are labelled in [unit]. The
/// marker sits at [valueMgDl], in [color].
///
/// It only reports where the user points, through [onChanged] (in mg/dL,
/// not rounded); the parent keeps the value.
class GlucoseBand extends StatelessWidget {
  /// Creates a band showing [valueMgDl].
  const GlucoseBand({
    super.key,
    required this.valueMgDl,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  /// The blood sugar to mark, in mg/dL.
  final double valueMgDl;

  /// The unit of the zone limit labels.
  final GlucoseUnit unit;

  /// The marker's color: the status color.
  final Color color;

  /// Called with the blood sugar in mg/dL under the user's finger.
  final ValueChanged<double> onChanged;

  /// The band's height: marker, band, ticks and labels.
  static const double height = 84;

  /// The space left and right, so the marker fits at the ends.
  static const double margin = 10;

  /// How long the marker takes to follow a new value.
  static const Duration _move = Duration(milliseconds: 120);

  /// The fraction (0–1) of the band at [valueMgDl].
  static double _fractionOf(double valueMgDl) =>
      (valueMgDl - minGlucoseMgDl) / (maxGlucoseMgDl - minGlucoseMgDl);

  /// The blood sugar in mg/dL at [dx] across a band [width] wide.
  static double valueAt(double dx, double width) =>
      minGlucoseMgDl +
      (dx / width).clamp(0.0, 1.0) * (maxGlucoseMgDl - minGlucoseMgDl);

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
          fontSize: 11,
          color: AppColors.caption,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    // The zones, from the bottom of the range to the top.
    final List<({double from, double to, Color color})> zones = [
      (
        from: minGlucoseMgDl,
        to: glucoseZoneLimits[0],
        color: VitalStatus.low.background,
      ),
      (
        from: glucoseZoneLimits[0],
        to: glucoseZoneLimits[1],
        color: VitalStatus.normal.background,
      ),
      (
        from: glucoseZoneLimits[1],
        to: glucoseZoneLimits[2],
        color: VitalStatus.elevated.background,
      ),
      (
        from: glucoseZoneLimits[2],
        to: maxGlucoseMgDl,
        color: VitalStatus.high.background,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: margin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = math.max(1, constraints.maxWidth);
          final double markerX = _fractionOf(valueMgDl) * width;
          // Horizontal drags only, so scrolling the screen over the band
          // doesn't change the value; a tap sets it too.
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) =>
                onChanged(valueAt(details.localPosition.dx, width)),
            onHorizontalDragStart: (details) =>
                onChanged(valueAt(details.localPosition.dx, width)),
            onHorizontalDragUpdate: (details) =>
                onChanged(valueAt(details.localPosition.dx, width)),
            child: SizedBox(
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The zones.
                  Positioned(
                    top: 34,
                    left: 0,
                    right: 0,
                    height: 14,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Row(
                        // Each zone fills the band's height.
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final zone in zones)
                            Expanded(
                              flex: (zone.to - zone.from).round(),
                              child: ColoredBox(color: zone.color),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // A tick and a label at each zone limit.
                  for (final double limit in glucoseZoneLimits) ...[
                    Positioned(
                      left: _fractionOf(limit) * width - 0.5,
                      top: 50,
                      child: Container(
                        width: 1,
                        height: 6,
                        color: AppColors.tick,
                      ),
                    ),
                    Positioned(
                      left: _fractionOf(limit) * width - 24,
                      top: 60,
                      width: 48,
                      child: Text(
                        unit.format(limit),
                        textAlign: TextAlign.center,
                        style: labelStyle,
                      ),
                    ),
                  ],
                  // The marker's stem, pointing into the band.
                  AnimatedPositioned(
                    duration: _move,
                    curve: Curves.easeOut,
                    left: markerX - 1,
                    top: 34,
                    child: AnimatedContainer(
                      duration: _move,
                      width: 2,
                      height: 16,
                      color: color,
                    ),
                  ),
                  // The drop: a square with three round corners, turned so
                  // the sharp corner points down at the stem.
                  AnimatedPositioned(
                    duration: _move,
                    curve: Curves.easeOut,
                    left: markerX - 15,
                    top: 4,
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: AnimatedContainer(
                        duration: _move,
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 3,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.text.withValues(alpha: 0.25),
                              blurRadius: 6,
                              // 2px straight down once turned by -45°.
                              offset: const Offset(-1.4, 1.4),
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
}
