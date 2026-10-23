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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/vitals/heart_rate.dart';
import '../../../models/vitals/vital_status.dart';
import '../../shared/widgets/round_icon_button.dart';
import '../../shared/widgets/status_chip.dart';
import 'beating_heart.dart';
import 'ecg_strip.dart';
import 'pulse_tap_button.dart';

/// The heart rate card: a header with the status, a beating heart with the
/// reading and the time between beats, a scrolling [EcgStrip] to drag, and
/// buttons to tap along with the pulse or step 1 bpm.
///
/// The heart and the trace both follow one animation that runs once per
/// beat, so they stay in time. With "reduce motion" on, they stand still.
/// Every change is reported through [onChanged].
class HeartRateCard extends StatefulWidget {
  /// Creates the card for [bpm].
  const HeartRateCard({
    super.key,
    required this.bpm,
    required this.onChanged,
    this.label = 'Heart rate',
  });

  /// The heart rate in beats per minute.
  final int bpm;

  /// Called with each new heart rate.
  final ValueChanged<int> onChanged;

  /// The card's title.
  final String label;

  @override
  State<HeartRateCard> createState() => _HeartRateCardState();
}

/// Holds the heart rate, the heartbeat animation and the pulse taps.
class _HeartRateCardState extends State<HeartRateCard>
    with SingleTickerProviderStateMixin {
  /// The heart rate shown. Updated right away while dragging or tapping, so
  /// the card doesn't wait for the data model.
  late int _bpm = clampBpm(widget.bpm);

  /// Runs from 0 to 1 once per heartbeat, over and over.
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: beatPeriod(_bpm),
  );

  /// The recent pulse taps, oldest first.
  List<DateTime> _taps = [];

  /// Ends the "Keep tapping" state a moment after the last tap.
  Timer? _tapTimer;

  /// Starts the heartbeat, unless the user asked for less motion.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartBeat();
  }

  /// Follows a heart rate changed from outside, e.g. by the agent.
  @override
  void didUpdateWidget(HeartRateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bpm != oldWidget.bpm && clampBpm(widget.bpm) != _bpm) {
      _bpm = clampBpm(widget.bpm);
      _restartBeat();
    }
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _beat.dispose();
    super.dispose();
  }

  /// Sets the animation to one run per beat at the current heart rate.
  void _restartBeat() {
    _beat.duration = beatPeriod(_bpm);
    if (MediaQuery.of(context).disableAnimations) {
      _beat.stop();
    } else {
      _beat.repeat();
    }
  }

  /// Sets the heart rate to [bpm] and reports it, if it is new.
  void _setBpm(int bpm) {
    final int clamped = clampBpm(bpm);
    if (clamped == _bpm) return;
    setState(() => _bpm = clamped);
    _restartBeat();
    widget.onChanged(clamped);
  }

  /// Steps 1 bpm up (+1) or down (-1).
  void _step(int direction) {
    HapticFeedback.selectionClick();
    _setBpm(_bpm + direction);
  }

  /// Counts one pulse tap; from the second tap on, sets the heart rate.
  void _onPulseTap() {
    HapticFeedback.lightImpact();
    setState(() => _taps = addPulseTap(_taps, DateTime.now()));
    final int? bpm = bpmFromTaps(_taps);
    if (bpm != null) _setBpm(bpm);
    _tapTimer?.cancel();
    _tapTimer = Timer(pulseTapTimeout + const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _taps = []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle base =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final VitalStatus status = heartRateStatus(_bpm);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: VitalStatus.normal.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: base.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.text,
                  ),
                ),
              ),
              StatusChip(
                label: status.label,
                color: status.color,
                background: status.background,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // The strip's slider already reads the heart rate out.
          ExcludeSemantics(
            child: Row(
              children: [
                BeatingHeart(beat: _beat, color: status.color),
                const SizedBox(width: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_bpm',
                      style: base.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: AppColors.text,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'bpm',
                      style: base.copyWith(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${beatPeriod(_bpm).inMilliseconds} ms\nbetween beats',
                  textAlign: TextAlign.right,
                  style: base.copyWith(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.caption,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          EcgStrip(
            bpm: _bpm,
            beat: _beat,
            color: status.color,
            onChanged: _setBpm,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PulseTapButton(
                  counting: _taps.isNotEmpty,
                  taps: _taps.length,
                  onTap: _onPulseTap,
                ),
              ),
              const SizedBox(width: 10),
              RoundIconButton(
                icon: Icons.remove_rounded,
                tooltip: 'Decrease',
                onPressed: _bpm > minBpm ? () => _step(-1) : null,
              ),
              const SizedBox(width: 10),
              RoundIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Increase',
                onPressed: _bpm < maxBpm ? () => _step(1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
