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

/// A drawn face that matches a 1–10 [severity]: a smile at 1, a flat mouth
/// around 5, a frown at 10, with frowning brows from 7.
///
/// The expression and [color] morph smoothly when either changes.
class SeverityFace extends StatelessWidget {
  /// Creates a face for [severity], [size] wide, in [color].
  const SeverityFace({
    super.key,
    required this.severity,
    required this.color,
    this.size = 30,
  });

  /// The severity from 1 to 10.
  final int severity;

  /// The face's color: the severity band's color.
  final Color color;

  /// The face's width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: severity.toDouble()),
      duration: const Duration(milliseconds: 200),
      builder: (context, shownSeverity, _) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration: const Duration(milliseconds: 200),
        builder: (context, shownColor, _) => CustomPaint(
          size: Size.square(size),
          painter: _FacePainter(
            severity: shownSeverity,
            color: shownColor ?? color,
          ),
        ),
      ),
    );
  }
}

/// Paints a [SeverityFace] in a 40×40 space, scaled to the widget's size.
class _FacePainter extends CustomPainter {
  /// Creates the painter for [severity] (may be between two whole numbers
  /// while animating) in [color].
  _FacePainter({required this.severity, required this.color});

  /// The severity from 1 to 10.
  final double severity;

  /// The line and eye color.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;

    // The face and the eyes.
    canvas
      ..drawCircle(const Offset(20, 20), 15, line)
      ..drawCircle(const Offset(14.5, 17), 1.9, fill)
      ..drawCircle(const Offset(25.5, 17), 1.9, fill);

    // The mouth: from a smile (k = 0) to a frown (k = 1).
    final double k = (severity - 1) / 9;
    final double y = 25.5 + 2 * k;
    final double curve = 6 - 14 * k;
    canvas.drawPath(
      Path()
        ..moveTo(14, y)
        ..quadraticBezierTo(20, y + curve, 26, y),
      line,
    );

    // Frowning brows from 7 up, lower as the severity rises.
    if (severity >= 7) {
      final double b = (severity - 6) / 4;
      final brow = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas
        ..drawLine(Offset(11, 12.5 + b), Offset(17, 13.5 + 2 * b), brow)
        ..drawLine(Offset(29, 12.5 + b), Offset(23, 13.5 + 2 * b), brow);
    }
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) =>
      severity != oldDelegate.severity || color != oldDelegate.color;
}
