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
import 'package:google_fonts/google_fonts.dart';

import '../../catalog/shared/catalog_item.dart';
import '../../core/theme/app_colors.dart';

import 'json_block.dart';

/// A card for one catalog component: its number and name, its description,
/// the live preview, and expandable sections with the example JSON and the
/// schema. Styled like the dashboard's cards: white on the warm page
/// background, with the app's fonts.
class ComponentCard extends StatelessWidget {
  /// Creates a card for [item], the [index]th (1-based) in its tab.
  const ComponentCard({
    super.key,
    required this.index,
    required this.item,
    required this.example,
    required this.preview,
  });

  /// The card's position in its tab, from 1, shown in a badge by the name.
  final int index;

  /// The component shown in this card.
  final CatalogItem item;

  /// The example A2UI components that the preview is rendered from.
  final List<JsonMap> example;

  /// The rendered preview: the example's surface, drawn by the screen.
  final Widget preview;

  /// Builds the card. The description is the item's, else the schema's, if
  /// there is one.
  @override
  Widget build(BuildContext context) {
    final Map<String, Object?> schema = item.dataSchema.value;
    final String? description =
        item.description ?? schema['description'] as String?;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IndexBadge(index),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.2,
                          color: AppColors.text,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: preview,
          ),
          const Divider(height: 1, color: AppColors.border),
          _Section(
            icon: Icons.data_object,
            title: 'Example A2UI JSON',
            child: JsonBlock(prettyJson.convert(example)),
          ),
          const Divider(height: 1, color: AppColors.border),
          _Section(
            icon: Icons.schema_outlined,
            title: 'Schema',
            child: JsonBlock(prettyJson.convert(schema)),
          ),
        ],
      ),
    );
  }
}

/// The card's number: a small round badge in the brand green.
class _IndexBadge extends StatelessWidget {
  /// Creates the badge for [index].
  const _IndexBadge(this.index);

  /// The number shown.
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$index',
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

/// An expandable section of the card, with [icon] and [title] in the app's
/// font, revealing [child].
class _Section extends StatelessWidget {
  /// Creates the section.
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  /// The icon at the section's left.
  final IconData icon;

  /// The section's name.
  final String title;

  /// What expanding the section reveals.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon, color: AppColors.text, size: 22),
      iconColor: AppColors.text,
      collapsedIconColor: AppColors.textMuted,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      children: [child],
    );
  }
}
