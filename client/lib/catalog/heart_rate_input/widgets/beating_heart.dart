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

/// A heart icon that beats once per run of [beat]: a big pulse, a smaller
/// second one, then a rest.
class BeatingHeart extends StatelessWidget {
  /// Creates a heart in [color] that beats with [beat] (0 → 1 per beat).
  const BeatingHeart({super.key, required this.beat, required this.color});

  /// Runs from 0 to 1 once per heartbeat.
  final Animation<double> beat;

  /// The heart's color.
  final Color color;

  /// The heart's size over one beat: up to 1.25 by 15%, back by 30%, up to
  /// 1.12 by 45%, back by 60%, then still.
  static final Animatable<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.25), weight: 15),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1), weight: 15),
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.12), weight: 15),
    TweenSequenceItem(tween: Tween(begin: 1.12, end: 1), weight: 15),
    TweenSequenceItem(tween: ConstantTween(1), weight: 40),
  ]);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 44,
      child: Center(
        child: ScaleTransition(
          scale: _scale.animate(beat),
          child: Icon(Icons.favorite_rounded, size: 34, color: color),
        ),
      ),
    );
  }
}
