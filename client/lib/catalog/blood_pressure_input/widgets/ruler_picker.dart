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
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// A horizontal ruler the user drags to pick a whole number.
///
/// The scale moves under a fixed center marker in [accentColor]: dragging
/// right lowers the value, like moving a tape measure. There is one tick per
/// unit, [pxPerUnit] apart, with a longer, labelled tick every [majorEvery]
/// units. A quick swipe keeps the scale gliding for a moment. The edges fade
/// out.
///
/// It only reports new values, through [onChanged]; the parent keeps
/// [value]. Screen readers see a slider that steps 1 at a time.
class RulerPicker extends StatefulWidget {
  /// Creates a ruler from [min] to [max] showing [value].
  const RulerPicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.accentColor,
    required this.onChanged,
    this.pxPerUnit = 8,
    this.majorEvery = 10,
    this.semanticLabel,
  });

  /// The picked value.
  final int value;

  /// The lowest value.
  final int min;

  /// The highest value.
  final int max;

  /// The color of the center marker.
  final Color accentColor;

  /// Called with each new whole value while the user drags.
  final ValueChanged<int> onChanged;

  /// The space between two ticks, in logical pixels.
  final double pxPerUnit;

  /// How often a labelled tick appears, e.g. every 10 units.
  final int majorEvery;

  /// What screen readers call the ruler, e.g. "Systolic".
  final String? semanticLabel;

  /// The ruler's height.
  static const double height = 52;

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

/// Tracks a drag or a glide, so the scale moves smoothly between whole
/// values.
class _RulerPickerState extends State<RulerPicker>
    with SingleTickerProviderStateMixin {
  /// Moves the scale after a quick swipe; its value is the ruler's value.
  late final AnimationController _glide = AnimationController.unbounded(
    vsync: this,
  )..addListener(_onGlide);

  /// Where the finger started, along the ruler.
  double _startDx = 0;

  /// The value when the drag started.
  double _startValue = 0;

  /// The exact (not rounded) value while dragging or gliding; `null` when
  /// the scale rests on [RulerPicker.value].
  double? _movingValue;

  /// The last value sent to [RulerPicker.onChanged], so each one is sent
  /// (and felt) only once.
  int? _lastSent;

  @override
  void dispose() {
    _glide.dispose();
    super.dispose();
  }

  /// [value] kept between the ruler's min and max.
  double _clamp(double value) =>
      value.clamp(widget.min.toDouble(), widget.max.toDouble());

  /// Shows the scale at [exact] and reports it rounded, if it is new.
  void _moveTo(double exact) {
    final double clamped = _clamp(exact);
    setState(() => _movingValue = clamped);
    final int rounded = clamped.round();
    if (rounded != widget.value && rounded != _lastSent) {
      _lastSent = rounded;
      HapticFeedback.selectionClick();
      widget.onChanged(rounded);
    }
  }

  /// Lets the scale rest on the picked whole value.
  void _settle() => setState(() {
    _movingValue = null;
    _lastSent = null;
  });

  void _onDragStart(DragStartDetails details) {
    _glide.stop();
    _startDx = details.localPosition.dx;
    _startValue = _movingValue ?? widget.value.toDouble();
  }

  void _onDragUpdate(DragUpdateDetails details) => _moveTo(
    _startValue - (details.localPosition.dx - _startDx) / widget.pxPerUnit,
  );

  /// Glides on after a quick swipe, slowing down; otherwise settles.
  void _onDragEnd(DragEndDetails details) {
    final double unitsPerSecond =
        -details.velocity.pixelsPerSecond.dx / widget.pxPerUnit;
    if (unitsPerSecond.abs() < 5 || _movingValue == null) {
      _settle();
      return;
    }
    _glide
        .animateWith(FrictionSimulation(0.05, _movingValue!, unitsPerSecond))
        .whenCompleteOrCancel(() {
          if (mounted && !_glide.isAnimating) _settle();
        });
  }

  /// Follows the glide, and stops it at either end of the ruler.
  void _onGlide() {
    _moveTo(_glide.value);
    if (_glide.value <= widget.min || _glide.value >= widget.max) {
      _glide.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
          fontSize: 11,
          color: AppColors.caption,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    final int value = widget.value;
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: '$value',
      increasedValue: '${(value + 1).clamp(widget.min, widget.max)}',
      decreasedValue: '${(value - 1).clamp(widget.min, widget.max)}',
      onIncrease: value < widget.max ? () => widget.onChanged(value + 1) : null,
      onDecrease: value > widget.min ? () => widget.onChanged(value - 1) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Container(
          height: RulerPicker.height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          // Fades the scale out at both ends. The mask only uses its colors'
          // opacity, so black and transparent here never show on screen.
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, 0.15, 0.85, 1],
            ).createShader(bounds),
            child: CustomPaint(
              size: Size.infinite,
              painter: _RulerPainter(
                value: _movingValue ?? value.toDouble(),
                min: widget.min,
                max: widget.max,
                pxPerUnit: widget.pxPerUnit,
                majorEvery: widget.majorEvery,
                accentColor: widget.accentColor,
                labelStyle: labelStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a [RulerPicker]'s ticks, labels and center marker.
class _RulerPainter extends CustomPainter {
  /// Creates a painter with the scale centered on [value].
  _RulerPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.pxPerUnit,
    required this.majorEvery,
    required this.accentColor,
    required this.labelStyle,
  });

  /// The value under the center marker; may be between two ticks.
  final double value;

  /// The first tick.
  final int min;

  /// The last tick.
  final int max;

  /// The space between ticks.
  final double pxPerUnit;

  /// How often a labelled tick appears.
  final int majorEvery;

  /// The center marker's color.
  final Color accentColor;

  /// The labels' text style.
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final minor = Paint()..color = AppColors.rulerMinorTick;
    final major = Paint()..color = AppColors.rulerMajorTick;

    // Only the ticks that fit in the visible width.
    final double halfUnits = centerX / pxPerUnit + 1;
    final int first = (value - halfUnits).floor().clamp(min, max);
    final int last = (value + halfUnits).ceil().clamp(min, max);
    for (var tick = first; tick <= last; tick++) {
      final double x = centerX - (value - tick) * pxPerUnit;
      final isMajor = tick % majorEvery == 0;
      canvas.drawRect(
        Rect.fromLTWH(x - 0.5, 6, 1, isMajor ? 20 : 10),
        isMajor ? major : minor,
      );
      if (!isMajor) continue;
      final label = TextPainter(
        text: TextSpan(text: '$tick', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      label
        ..paint(canvas, Offset(x - label.width / 2, 30))
        ..dispose();
    }

    // The center marker.
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - 1.5, 0, 3, 30),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = accentColor,
    );
  }

  @override
  bool shouldRepaint(_RulerPainter oldDelegate) =>
      value != oldDelegate.value ||
      accentColor != oldDelegate.accentColor ||
      min != oldDelegate.min ||
      max != oldDelegate.max ||
      pxPerUnit != oldDelegate.pxPerUnit ||
      majorEvery != oldDelegate.majorEvery ||
      labelStyle != oldDelegate.labelStyle;
}
