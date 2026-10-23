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

import 'vital_status.dart';

// The rules behind HeartRateInput: the range, the status, the time between
// beats and counting beats from taps.

/// The lowest heart rate, in beats per minute.
const int minBpm = 40;

/// The highest heart rate, in beats per minute.
const int maxBpm = 200;

/// The heart rate shown before the user picks one.
const int defaultBpm = 72;

/// How many recent taps [bpmFromTaps] averages.
const int maxPulseTaps = 6;

/// A pause longer than this starts a new count of taps.
const Duration pulseTapTimeout = Duration(seconds: 3);

/// [bpm] kept between [minBpm] and [maxBpm].
int clampBpm(num bpm) => bpm.round().clamp(minBpm, maxBpm);

/// The status of a resting heart rate: under 60 is low, over 100 is high.
/// A general adult guide, not a diagnosis.
VitalStatus heartRateStatus(int bpm) {
  if (bpm < 60) return VitalStatus.low;
  if (bpm > 100) return VitalStatus.high;
  return VitalStatus.normal;
}

/// The time between two beats at [bpm], e.g. 833 ms at 72 bpm.
Duration beatPeriod(int bpm) =>
    Duration(milliseconds: (60000 / bpm.clamp(1, maxBpm)).round());

/// The taps to keep after a tap at [now]: [taps] plus [now], or only [now]
/// after a pause longer than [pulseTapTimeout], and at most [maxPulseTaps].
List<DateTime> addPulseTap(List<DateTime> taps, DateTime now) {
  final bool paused =
      taps.isNotEmpty && now.difference(taps.last) > pulseTapTimeout;
  final kept = <DateTime>[if (!paused) ...taps, now];
  return kept.length > maxPulseTaps
      ? kept.sublist(kept.length - maxPulseTaps)
      : kept;
}

/// The heart rate from [taps] (one per beat): 60 000 ms divided by the
/// average time between them. `null` with fewer than two taps.
int? bpmFromTaps(List<DateTime> taps) {
  if (taps.length < 2) return null;
  final int totalMs = taps.last.difference(taps.first).inMilliseconds;
  final double averageMs = totalMs / (taps.length - 1);
  if (averageMs <= 0) return null;
  return clampBpm(60000 / averageMs);
}
