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

import 'json_block.dart';

/// The content of the bottom sheet that shows a preview's action: a title
/// above a [JsonBlock].
class JsonSheet extends StatelessWidget {
  /// Creates a sheet with [title] and [json].
  const JsonSheet({super.key, required this.title, required this.json});

  /// The heading at the top of the sheet.
  final String title;

  /// The JSON text to show, already formatted.
  final String json;

  /// Builds the sheet; the JSON scrolls if it is taller than the screen.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(child: SingleChildScrollView(child: JsonBlock(json))),
          ],
        ),
      ),
    );
  }
}
