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

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as pretty;
import 'package:logging/logging.dart';

/// Prints colored, level-tagged lines. Warnings and errors are boxed so they
/// stand out, together with their stack traces.
final pretty.Logger _console = pretty.Logger(
  level: pretty.Level.trace,
  printer: pretty.PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 100,
    dateTimeFormat: pretty.DateTimeFormat.none,
    noBoxingByDefault: true,
    excludeBox: const {
      pretty.Level.warning: false,
      pretty.Level.error: false,
      pretty.Level.fatal: false,
    },
  ),
);

/// The listener on [Logger.root] set up by [setupLogging].
///
/// It is kept so that calling [setupLogging] again (e.g. after a hot restart)
/// cancels the old listener and lines are not printed twice.
StreamSubscription<LogRecord>? _subscription;

/// Routes every [Logger] in the app (and in packages that also use
/// `package:logging`) to a colored console printer from `package:logger`:
///
/// ```text
/// 💡 12:34:56.789 [GenUiSession] GenUiSession → Transport.sendRequest
/// ```
///
/// Colors by level: FINER/FINEST grey, FINE default, INFO blue,
/// WARNING orange, SEVERE red, SHOUT pink. Output appears in debug builds;
/// release builds only keep warnings and errors.
///
/// The values the user enters (health data) are logged at FINEST only.
void setupLogging() {
  Logger.root.level = kReleaseMode ? Level.WARNING : Level.ALL;
  _subscription?.cancel();
  _subscription = Logger.root.onRecord.listen((record) {
    final String time = record.time.toIso8601String().substring(11, 23);
    _console.log(
      _levelFor(record.level),
      '$time [${record.loggerName}] ${record.message}',
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
}

/// Maps a `package:logging` [level] to the matching `package:logger` level,
/// which picks the color and the emoji of the printed line.
pretty.Level _levelFor(Level level) {
  if (level >= Level.SHOUT) return pretty.Level.fatal;
  if (level >= Level.SEVERE) return pretty.Level.error;
  if (level >= Level.WARNING) return pretty.Level.warning;
  if (level >= Level.INFO) return pretty.Level.info;
  if (level >= Level.FINE) return pretty.Level.debug;
  return pretty.Level.trace;
}

/// Shortens long payloads (prompts, model chunks, JSON) for log output.
///
/// Line breaks are shown as `\n` so each log entry stays on one line. Texts
/// longer than [max] characters are cut and end with their full length.
String preview(Object? value, {int max = 120}) {
  final String text = '$value'.replaceAll('\n', r'\n');
  if (text.length <= max) return text;
  return '${text.substring(0, max)}… (${text.length} chars)';
}
