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
import '../../../models/vitals/temperature.dart';

/// A horizontal thermometer the user drags (or taps) to set a temperature.
///
/// A bulb on the left, a tube filled up to [tempC] in [color] with a dark
/// marker at the end of the fill, and a scale underneath: a tick every
/// 0.5 °C and a label at every whole degree, in [unit].
///
/// It only reports where the user points, through [onChanged] (in °C, not
/// rounded); the parent keeps the value. Screen readers see a slider that
/// steps 0.1 °C at a time.
class Thermometer extends StatelessWidget {
  /// Creates a thermometer showing [tempC].
  const Thermometer({
    super.key,
    required this.tempC,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  /// The temperature to show, in °C.
  final double tempC;

  /// The unit of the scale labels.
  final TempUnit unit;

  /// The color of the bulb and the fill: the status color.
  final Color color;

  /// Called with the temperature in °C under the user's finger.
  final ValueChanged<double> onChanged;

  /// The thermometer's height: tube, marker, ticks and labels.
  static const double height = 76;

  /// The temperature in °C at [dx] across a thermometer [width] wide.
  static double tempAt(double dx, double width) {
    final double fraction =
        (dx - _Geometry.tubeLeft) / _Geometry.tubeWidth(width);
    return minTempC + fraction.clamp(0.0, 1.0) * (maxTempC - minTempC);
  }

  /// The x position of [tempC] (in °C) across a thermometer [width] wide.
  static double xOf(double tempC, double width) => _Geometry.xOf(tempC, width);

  /// [valueC], a temperature in °C, as text in [unit], e.g. "36.6 °C".
  String _describe(double valueC) =>
      '${unit.fromCelsius(valueC).toStringAsFixed(1)} ${unit.symbol}';

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
          fontSize: 11,
          color: AppColors.caption,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    return Semantics(
      slider: true,
      label: 'Temperature',
      value: _describe(tempC),
      increasedValue: _describe(roundTempC(tempC + 0.1)),
      decreasedValue: _describe(roundTempC(tempC - 0.1)),
      onIncrease: () => onChanged(tempC + 0.1),
      onDecrease: () => onChanged(tempC - 0.1),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          // Horizontal drags only, so scrolling the screen over the
          // thermometer doesn't change the temperature; a tap sets it too.
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) =>
                onChanged(tempAt(details.localPosition.dx, width)),
            onHorizontalDragStart: (details) =>
                onChanged(tempAt(details.localPosition.dx, width)),
            onHorizontalDragUpdate: (details) =>
                onChanged(tempAt(details.localPosition.dx, width)),
            // Animates the fill's length and color between readings.
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: tempC),
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              builder: (context, shownTempC, _) =>
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: color),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, shownColor, _) => CustomPaint(
                      size: Size(width, height),
                      painter: _ThermometerPainter(
                        tempC: shownTempC,
                        color: shownColor ?? color,
                        unit: unit,
                        labelStyle: labelStyle,
                      ),
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}

/// Where each part of the thermometer goes, in logical pixels.
abstract final class _Geometry {
  /// The bulb's diameter.
  static const double bulb = 44;

  /// The colored circle's diameter inside the bulb.
  static const double bulbInner = 32;

  /// The vertical center of the bulb and the tube.
  static const double centerY = bulb / 2;

  /// Where the tube (and the scale) starts.
  static const double tubeLeft = 38;

  /// The gap between the tube's end and the right edge.
  static const double tubeEndGap = 6;

  /// The tube's height.
  static const double tubeHeight = 20;

  /// The gap between the tube's wall and the fill, top and bottom.
  static const double fillInset = 4;

  /// The marker's width and height.
  static const Size marker = Size(4, 32);

  /// Where the ticks start, under the tube.
  static const double scaleTop = 46;

  /// How long a tick at a whole degree is.
  static const double majorTick = 10;

  /// How long a tick at a half degree is.
  static const double minorTick = 5;

  /// Where the labels start.
  static const double labelTop = 60;

  /// The tube's length in a thermometer [width] wide.
  static double tubeWidth(double width) =>
      math.max(1, width - tubeEndGap - tubeLeft);

  /// The x position of [tempC] in a thermometer [width] wide.
  static double xOf(double tempC, double width) =>
      tubeLeft + (tempC - minTempC) / (maxTempC - minTempC) * tubeWidth(width);
}

/// Paints the bulb, tube, fill, marker and scale of a [Thermometer].
class _ThermometerPainter extends CustomPainter {
  /// Creates a painter for [tempC] in [color], labelled in [unit].
  _ThermometerPainter({
    required this.tempC,
    required this.color,
    required this.unit,
    required this.labelStyle,
  });

  /// The temperature to fill up to, in °C.
  final double tempC;

  /// The bulb and fill color.
  final Color color;

  /// The unit of the scale labels.
  final TempUnit unit;

  /// The scale labels' text style.
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const double cy = _Geometry.centerY;
    const double tubeTop = cy - _Geometry.tubeHeight / 2;
    const double tubeBottom = cy + _Geometry.tubeHeight / 2;
    final double tubeRight = size.width - _Geometry.tubeEndGap;
    const bulbCenter = Offset(_Geometry.bulb / 2, cy);
    final field = Paint()..color = AppColors.field;
    final border = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 1. The bulb.
    canvas
      ..drawCircle(bulbCenter, _Geometry.bulb / 2, field)
      ..drawCircle(bulbCenter, _Geometry.bulb / 2 - 0.5, border);

    // 2. The tube: its fill covers the bulb's outline where they meet, so
    // the tube opens into the bulb. Its outline is the top, the rounded
    // right end and the bottom, from where they meet the bulb.
    const double radius = _Geometry.tubeHeight / 2;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        _Geometry.tubeLeft,
        tubeTop,
        tubeRight,
        tubeBottom,
        topRight: const Radius.circular(radius),
        bottomRight: const Radius.circular(radius),
      ),
      field,
    );
    // Where the tube's top and bottom lines cross the bulb's circle.
    final double meetX =
        bulbCenter.dx +
        math.sqrt(
          math.pow(_Geometry.bulb / 2, 2) -
              math.pow(_Geometry.tubeHeight / 2, 2),
        );
    canvas.drawPath(
      Path()
        ..moveTo(meetX, tubeTop + 0.5)
        ..lineTo(tubeRight - radius, tubeTop + 0.5)
        ..arcToPoint(
          Offset(tubeRight - radius, tubeBottom - 0.5),
          radius: const Radius.circular(radius - 0.5),
        )
        ..lineTo(meetX, tubeBottom - 0.5),
      border,
    );

    // 3. The colored circle in the bulb and the fill up to [tempC].
    final fill = Paint()..color = color;
    canvas.drawCircle(bulbCenter, _Geometry.bulbInner / 2, fill);
    final double fillRight = _Geometry.xOf(tempC, size.width);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        bulbCenter.dx,
        tubeTop + _Geometry.fillInset,
        math.max(fillRight, bulbCenter.dx),
        tubeBottom - _Geometry.fillInset,
        topRight: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ),
      fill,
    );

    // 4. The marker at the end of the fill.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(fillRight, cy),
          width: _Geometry.marker.width,
          height: _Geometry.marker.height,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.text,
    );

    // 5. The scale: a tick every 0.5 °C, a label at every whole degree.
    final tick = Paint()
      ..color = AppColors.tick
      ..strokeWidth = 1;
    for (var halfDegrees = 0; halfDegrees <= 16; halfDegrees++) {
      final double celsius = minTempC + halfDegrees / 2;
      final double x = _Geometry.xOf(celsius, size.width);
      final bool whole = halfDegrees.isEven;
      canvas.drawLine(
        Offset(x, _Geometry.scaleTop),
        Offset(
          x,
          _Geometry.scaleTop +
              (whole ? _Geometry.majorTick : _Geometry.minorTick),
        ),
        tick,
      );
      if (!whole) continue;
      final label = TextPainter(
        text: TextSpan(
          text: unit.fromCelsius(celsius).round().toString(),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Centered under its tick, but kept inside the thermometer.
      final double left = (x - label.width / 2).clamp(
        0.0,
        math.max(0.0, size.width - label.width),
      );
      label
        ..paint(canvas, Offset(left, _Geometry.labelTop))
        ..dispose();
    }
  }

  @override
  bool shouldRepaint(_ThermometerPainter oldDelegate) =>
      tempC != oldDelegate.tempC ||
      color != oldDelegate.color ||
      unit != oldDelegate.unit ||
      labelStyle != oldDelegate.labelStyle;
}
