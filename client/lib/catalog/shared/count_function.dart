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

import 'package:a2ui_core/a2ui_core.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The app's one custom function, `count`: how many characters a text has,
/// or how many items a list or map has (0 for anything else).
///
/// The A2UI v1.0 basic catalog can check a length (`length` with `min` and
/// `max`) but can't return one. The screens show counts ("3 foods",
/// "11 / 280") and pick a text by whether something was typed
/// (`pluralize(value:${count(value:${/notes})}, zero:'No notes', ...)`), so
/// the app's catalog adds this next to the basic functions.
class CountFunction extends FunctionImplementation {
  /// Creates the function.
  CountFunction()
    : super(
        name: 'count',
        returnType: A2uiReturnType.number,
        description:
            'Returns the number of characters in a string, or the number of '
            'items in a list or map. Any other value counts as 0.',
        argumentSchema: Schema.object(
          properties: {'value': CommonSchemasV1.dynamicValue},
        ),
      );

  @override
  Object? execute(
    Map<String, dynamic> args,
    DataContext context, [
    CancellationSignal? cancellationSignal,
  ]) => switch (args['value']) {
    final String text => text.length,
    final List<Object?> list => list.length,
    final Map<Object?, Object?> map => map.length,
    _ => 0,
  };
}
