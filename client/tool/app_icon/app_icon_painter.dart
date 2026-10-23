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

/// Draws the app icon for VitalLoop: a cream ring (the loop) closed across
/// its middle by a heartbeat line (the vitals), with an amber bead on the
/// ring, on the app's deep-green background.
///
/// Everything is drawn in code, so the icon can be changed here and every
/// platform's image files rebuilt with `generate_icons_test.dart`.
library;

import 'dart:ui';

/// The lighter green at the top-left of the background gradient.
const Color iconGreenLight = Color(0xFF3D6656);

/// The darker green at the bottom-right of the background gradient.
const Color iconGreenDark = Color(0xFF1E352C);

/// The ring and pulse's cream color, the same as the theme's `background`
/// color.
const Color iconCream = Color(0xFFF4F0EA);

/// The bead's warm amber, the icon's one accent color.
const Color iconAmber = Color(0xFFE8B04B);

/// Which version of the icon to draw. Each platform needs a slightly
/// different one.
enum IconVariant {
  /// Square, edge to edge, no transparency. iOS rounds the corners itself.
  fullBleed,

  /// A rounded square on a transparent canvas: the Android launcher icon
  /// for phones without adaptive icons, and the web icons and favicon.
  rounded,

  /// Edge to edge with a smaller symbol, so it survives any mask shape:
  /// the web's "maskable" icons.
  maskable,

  /// Only the symbol, on transparency: the foreground layer of the Android
  /// adaptive icon. The background layer is `ic_launcher_background.xml`.
  adaptiveForeground,

  /// The symbol in plain white on transparency: the Android 13+ themed icon,
  /// which the system recolors.
  monochrome,
}

/// How wide the symbol's 88-unit design area is drawn, as a share of the
/// canvas, per [IconVariant].
///
/// Android's adaptive canvas is 108dp, of which only the middle 72dp shows
/// (and only a 66dp circle is safe), and maskable web icons keep everything
/// inside the middle 80% circle, so their symbol is smaller. The symbol is
/// round, so it fits those circles at a larger share than a square would.
double _symbolWidth(IconVariant variant) => switch (variant) {
  IconVariant.fullBleed => 0.66,
  IconVariant.rounded => 0.62,
  IconVariant.maskable => 0.56,
  IconVariant.adaptiveForeground || IconVariant.monochrome => 0.50,
};

/// The symbol's design box is 100 x 100, centered on (50, 50).
const double _center = 50;

/// The ring's radius, to the middle of its stroke.
const double _ringRadius = 34;

/// How thick the ring and the heartbeat line are drawn.
const double _ringStroke = 10;
const double _pulseStroke = 8;

/// The amber bead on the ring, at its top right, and the gap cut around it.
const Offset _bead = Offset(74.04, 25.96); // 45 degrees up the ring.
const double _beadRadius = 8;
const double _beadGap = 4;

/// The heartbeat line: flat from the ring's left side, one beat (a small
/// dip, a tall spike down then up, a small bump), then flat to the ring's
/// right side, so the line closes the loop.
Path _pulsePath() => Path()
  ..moveTo(_center - _ringRadius, 52)
  ..lineTo(33, 52)
  ..lineTo(39, 42)
  ..lineTo(47, 66)
  ..lineTo(56, 30)
  ..lineTo(63, 58)
  ..lineTo(68, 52)
  ..lineTo(_center + _ringRadius, 52);

/// Draws the icon's [variant] on [canvas], filling a [size] x [size] square.
void paintAppIcon(Canvas canvas, double size, IconVariant variant) {
  final bounds = Rect.fromLTWH(0, 0, size, size);
  final background = Paint()
    ..shader = Gradient.linear(bounds.topLeft, bounds.bottomRight, const [
      iconGreenLight,
      iconGreenDark,
    ]);

  switch (variant) {
    case IconVariant.fullBleed:
    case IconVariant.maskable:
      canvas.drawRect(bounds, background);
    case IconVariant.rounded:
      // A small margin, like other launcher icons, and corners that match
      // the usual "squircle" look.
      final Rect square = bounds.deflate(size * 0.04);
      canvas.drawRRect(
        RRect.fromRectAndRadius(square, Radius.circular(size * 0.22)),
        background,
      );
    case IconVariant.adaptiveForeground:
    case IconVariant.monochrome:
      break; // Transparent: Android draws the background layer.
  }

  // Scale the 100-unit design box so its middle 88 units have the right
  // width, and center the box on the canvas.
  final double scale = size * _symbolWidth(variant) / 88;
  canvas.save();
  canvas.translate(size / 2 - _center * scale, size / 2 - _center * scale);
  canvas.scale(scale);

  // The themed (monochrome) icon is one color, which the system tints.
  final mono = variant == IconVariant.monochrome;
  final Color cream = mono ? const Color(0xFFFFFFFF) : iconCream;
  final Color amber = mono ? const Color(0xFFFFFFFF) : iconAmber;

  // The ring and pulse go on their own layer, so the gap around the bead
  // can be cut out of them and show whatever is behind: the green, or
  // transparency on Android's layers.
  canvas.saveLayer(const Rect.fromLTWH(0, 0, 100, 100), Paint());
  canvas.drawCircle(
    const Offset(_center, _center),
    _ringRadius,
    Paint()
      ..color = cream
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke,
  );
  canvas.drawPath(
    _pulsePath(),
    Paint()
      ..color = cream
      ..style = PaintingStyle.stroke
      ..strokeWidth = _pulseStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawCircle(
    _bead,
    _beadRadius + _beadGap,
    Paint()..blendMode = BlendMode.clear,
  );
  canvas.restore();

  canvas.drawCircle(_bead, _beadRadius, Paint()..color = amber);
  canvas.restore();
}
