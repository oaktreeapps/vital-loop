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
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/vitals/heart_rate.dart';

/// A scrolling ECG trace on graph paper, drawn for [bpm]. Dragging it
/// sideways changes the heart rate: right raises it, 1 bpm per 3 px.
///
/// The trace moves left by one heartbeat per run of [beat], so it loops
/// without a seam. Everything is painted by one painter. Screen readers see
/// a slider that steps 1 bpm.
class EcgStrip extends StatefulWidget {
  /// Creates the strip for [bpm], in [color].
  const EcgStrip({
    super.key,
    required this.bpm,
    required this.beat,
    required this.color,
    required this.onChanged,
  });

  /// The heart rate to draw, in beats per minute.
  final int bpm;

  /// Runs from 0 to 1 once per heartbeat; scrolls the trace.
  final Animation<double> beat;

  /// The trace's color: the status color.
  final Color color;

  /// Called with each new heart rate while the user drags.
  final ValueChanged<int> onChanged;

  /// The strip's height.
  static const double height = 104;

  /// How far the trace moves per second: about 25 mm/s on paper.
  static const double pxPerSecond = 95;

  /// How many pixels of drag change the heart rate by 1 bpm.
  static const double pxPerBpm = 3;

  @override
  State<EcgStrip> createState() => _EcgStripState();
}

/// Remembers where a drag started.
class _EcgStripState extends State<EcgStrip> {
  /// Where the finger started.
  double _startDx = 0;

  /// The heart rate when the drag started.
  int _startBpm = defaultBpm;

  /// The last heart rate sent, so each one is sent (and felt) only once.
  int? _lastSent;

  void _onDragUpdate(DragUpdateDetails details) {
    final int bpm = clampBpm(
      _startBpm + (details.localPosition.dx - _startDx) / EcgStrip.pxPerBpm,
    );
    if (bpm == widget.bpm || bpm == _lastSent) return;
    _lastSent = bpm;
    HapticFeedback.selectionClick();
    widget.onChanged(bpm);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int bpm = widget.bpm;
    return Semantics(
      slider: true,
      label: 'Heart rate',
      value: '$bpm beats per minute',
      increasedValue: '${clampBpm(bpm + 1)} beats per minute',
      decreasedValue: '${clampBpm(bpm - 1)} beats per minute',
      onIncrease: bpm < maxBpm ? () => widget.onChanged(bpm + 1) : null,
      onDecrease: bpm > minBpm ? () => widget.onChanged(bpm - 1) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          _startDx = details.localPosition.dx;
          _startBpm = widget.bpm;
          _lastSent = null;
        },
        onHorizontalDragUpdate: _onDragUpdate,
        child: Container(
          height: EcgStrip.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _EcgPainter(
                    beat: widget.beat,
                    beatPx: EcgStrip.pxPerSecond * 60 / bpm,
                    color: widget.color,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 10,
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LEAD II · 25 mm/s',
                        style: text.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.eyebrow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 8,
                child: ExcludeSemantics(
                  child: Text(
                    'Drag to adjust',
                    style: text.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.caption,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the graph paper and the ECG trace of an [EcgStrip].
class _EcgPainter extends CustomPainter {
  /// Creates a painter that scrolls with [beat], one beat [beatPx] wide.
  _EcgPainter({required this.beat, required this.beatPx, required this.color})
    : super(repaint: beat);

  /// Runs from 0 to 1 once per heartbeat.
  final Animation<double> beat;

  /// The width of one heartbeat on the strip.
  final double beatPx;

  /// The trace's color.
  final Color color;

  /// The trace's resting line.
  static const double baseline = 62;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);

    // One heartbeat after another, shifted left as the beat runs.
    final double start = -beat.value * beatPx;
    final path = Path()..moveTo(start, baseline);
    for (var x0 = start; x0 < size.width + beatPx; x0 += beatPx) {
      _addBeat(path, x0);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Graph paper: a light line every 8 px, a darker one every 40 px.
  void _paintGrid(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = AppColors.border.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 8) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        x % 40 == 0 ? major : minor,
      );
    }
    for (double y = 0; y <= size.height; y += 8) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        y % 40 == 0 ? major : minor,
      );
    }
  }

  /// Adds one heartbeat starting at [x0]: the P wave, the QRS spike and the
  /// T wave, with flat stretches between them.
  void _addBeat(Path path, double x0) {
    double x(double fraction) => x0 + fraction * beatPx;
    const double y = baseline;
    path
      ..lineTo(x(0.10), y)
      // P wave: a small bump up to 7 px.
      ..quadraticBezierTo(x(0.15), y - 14, x(0.20), y)
      ..lineTo(x(0.27), y)
      // QRS: a dip, the tall spike, a deeper dip, back to the line.
      ..lineTo(x(0.29), y + 5)
      ..lineTo(x(0.31), y - 40)
      ..lineTo(x(0.335), y + 14)
      ..lineTo(x(0.355), y)
      ..lineTo(x(0.44), y)
      // T wave: a wider bump up to 14 px.
      ..quadraticBezierTo(x(0.53), y - 28, x(0.62), y)
      ..lineTo(x(1.0), y);
  }

  @override
  bool shouldRepaint(_EcgPainter oldDelegate) =>
      beatPx != oldDelegate.beatPx ||
      color != oldDelegate.color ||
      beat != oldDelegate.beat;
}
