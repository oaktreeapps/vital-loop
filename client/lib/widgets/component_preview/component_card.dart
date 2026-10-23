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
import 'package:genui/genui.dart';

import 'json_block.dart';

/// A card for one catalog component: its name and description, the live
/// preview, and expandable sections with the example JSON and the schema.
class ComponentCard extends StatelessWidget {
  /// Creates a card for [item].
  const ComponentCard({
    super.key,
    required this.item,
    required this.example,
    required this.preview,
  });

  /// The component shown in this card.
  final CatalogItem item;

  /// The example A2UI components that the preview is rendered from.
  final List<JsonMap> example;

  /// The rendered preview, a [Surface] made by the screen's controller.
  final Widget preview;

  /// Builds the card. The description comes from the schema, if it has one.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, Object?> schema = item.dataSchema.value;
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (schema['description'] case final String description) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(8), child: preview),
          ExpansionTile(
            leading: const Icon(Icons.data_object),
            title: const Text('Example A2UI JSON'),
            children: [JsonBlock(prettyJson.convert(example))],
          ),
          ExpansionTile(
            leading: const Icon(Icons.schema_outlined),
            title: const Text('Schema'),
            children: [JsonBlock(prettyJson.convert(schema))],
          ),
        ],
      ),
    );
  }
}
