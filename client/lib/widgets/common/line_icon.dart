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

/// A 2px-stroke outline icon drawn on a 24×24 grid, for shapes the Material
/// and Cupertino icon fonts don't have.
class LineIcon extends StatelessWidget {
  /// Creates a [shape] icon in [color], [size] pixels wide and tall.
  const LineIcon(this.shape, {super.key, required this.color, this.size = 24});

  /// Which icon to draw.
  final LineIconShape shape;

  /// The stroke color.
  final Color color;

  /// The width and height of the icon, in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LineIconPainter(shape, color),
    );
  }
}

/// The icons [LineIcon] can draw.
enum LineIconShape {
  /// A heart with a pulse line through it.
  heartPulse,

  /// A diagonal two-part capsule.
  pill,

  /// A bowl with steam rising from it.
  soupBowl,
}

/// Paints a [LineIconShape] for [LineIcon].
///
/// The paths are written for a 24×24 grid and scaled to the real size.
class _LineIconPainter extends CustomPainter {
  /// Creates a painter for [shape] in [color].
  _LineIconPainter(this.shape, this.color);

  /// Which icon to draw.
  final LineIconShape shape;

  /// The stroke color.
  final Color color;

  /// Scales the canvas to the 24×24 grid and strokes every path of [shape].
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final Path path in _paths(shape)) {
      canvas.drawPath(path, paint);
    }
  }

  /// The outline paths of [shape], in 24×24 grid units.
  ///
  /// Each path is stroked, not filled, so a shape can have several open
  /// lines (like the steam over the soup bowl).
  static List<Path> _paths(LineIconShape shape) => switch (shape) {
    LineIconShape.heartPulse => [
      Path()
        ..moveTo(19, 14)
        ..cubicTo(20.49, 12.54, 22, 10.79, 22, 8.5)
        ..arcToPoint(
          const Offset(16.5, 3),
          radius: const Radius.circular(5.5),
          clockwise: false,
        )
        ..cubicTo(14.74, 3, 13.5, 3.5, 12, 5)
        ..cubicTo(10.5, 3.5, 9.26, 3, 7.5, 3)
        ..arcToPoint(
          const Offset(2, 8.5),
          radius: const Radius.circular(5.5),
          clockwise: false,
        )
        ..cubicTo(2, 10.8, 3.5, 12.55, 5, 14)
        ..lineTo(12, 21)
        ..close(),
      Path()
        ..moveTo(3.2, 12)
        ..lineTo(9.5, 12)
        ..lineTo(10, 11)
        ..lineTo(12, 15.5)
        ..lineTo(14, 8.5)
        ..lineTo(15.5, 12)
        ..lineTo(20.8, 12),
    ],
    LineIconShape.pill => [
      Path()
        ..moveTo(10.5, 20.5)
        ..lineTo(20.5, 10.5)
        ..arcToPoint(
          const Offset(13.5, 3.5),
          radius: const Radius.circular(4.95),
          largeArc: true,
          clockwise: false,
        )
        ..lineTo(3.5, 13.5)
        ..arcToPoint(
          const Offset(10.5, 20.5),
          radius: const Radius.circular(4.95),
          largeArc: true,
          clockwise: false,
        )
        ..close(),
      Path()
        ..moveTo(8.5, 8.5)
        ..lineTo(15.5, 15.5),
    ],
    LineIconShape.soupBowl => [
      // Bowl: a half circle under its rim.
      Path()
        ..moveTo(3, 12)
        ..lineTo(21, 12)
        ..arcToPoint(const Offset(3, 12), radius: const Radius.circular(9))
        ..close(),
      // Steam.
      for (final double x in [7.5, 12, 16.5])
        Path()
          ..moveTo(x, 8.5)
          ..cubicTo(x - 1.4, 7.4, x + 1.4, 5.1, x, 4),
    ],
  };

  /// Repaints only when the shape or the color changes.
  @override
  bool shouldRepaint(_LineIconPainter old) =>
      old.shape != shape || old.color != color;
}
