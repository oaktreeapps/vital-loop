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

// Checks genui's validation of streamed screens: errors from checks of older
// partial screens are expected, but the final screen must still be checked.

import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:logging/logging.dart';
import 'package:vitalloop/flows/vitals_flow.dart';

/// An updateComponents with a root Column and [count] Text lines; the last
/// one is invalid when [invalidLast] is set.
Map<String, Object?> _update(int count, {bool invalidLast = false}) => {
  'version': 'v0.9',
  'updateComponents': {
    'surfaceId': 's',
    'components': [
      {
        'id': 'root',
        'component': 'Column',
        'children': [for (var i = 0; i < count; i++) 't$i'],
      },
      for (var i = 0; i < count; i++)
        invalidLast && i == count - 1
            ? {'id': 't$i', 'component': 'Text', 'text': 12345}
            : {'id': 't$i', 'component': 'Text', 'text': 'Line $i'},
    ],
  },
};

void main() {
  // app_logging.dart hides genui's "Unexpected error during surface
  // validation" ConcurrentModificationErrors. That is only safe while they come
  // from checks of replaced partial screens and the final screen is still
  // checked; this test pins both.
  test(
    'a streamed screen: older checks fail, the final one still runs',
    () async {
      final Level oldLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      addTearDown(() => Logger.root.level = oldLevel);

      final records = <LogRecord>[];
      final finalChecked = Completer<void>();
      final StreamSubscription<LogRecord> sub = Logger.root.onRecord.listen((
        record,
      ) {
        records.add(record);
        if (_isFinalWarning(record) && !finalChecked.isCompleted) {
          finalChecked.complete();
        }
      });
      addTearDown(sub.cancel);

      final controller = SurfaceController(catalogs: [vitalsFlow.catalog]);
      addTearDown(controller.dispose);
      controller.handleMessage(
        core.A2uiMessage.fromJson({
          'version': 'v0.9',
          'createSurface': {
            'surfaceId': 's',
            'catalogId': vitalsFlow.catalog.catalogId,
          },
        }),
      );
      // Partial screens arriving faster than genui checks them.
      for (var count = 1; count <= 12; count++) {
        controller.handleMessage(core.A2uiMessage.fromJson(_update(count)));
        await Future<void>.delayed(Duration.zero);
      }
      controller.handleMessage(
        core.A2uiMessage.fromJson(_update(13, invalidLast: true)),
      );
      // Wait for the final screen's check to report its bad component, then
      // let any older checks still in the event queue finish.
      await finalChecked.future.timeout(const Duration(seconds: 15));
      await pumpEventQueue();

      final List<LogRecord> severe = records
          .where((r) => r.level >= Level.SEVERE)
          .toList();
      for (final record in severe) {
        expect(record.message, 'Unexpected error during surface validation');
        expect(record.error, isA<ConcurrentModificationError>());
      }
      expect(
        records.where(_isFinalWarning),
        hasLength(1),
        reason: 'the final screen is checked and its bad component reported',
      );
    },
  );
}

/// Whether [record] is genui's warning for the invalid last component (`t12`)
/// of the final screen, which means the final screen was fully checked.
bool _isFinalWarning(LogRecord record) =>
    record.level == Level.WARNING &&
    record.message.contains('Schema validation failed') &&
    record.message.contains('t12');
