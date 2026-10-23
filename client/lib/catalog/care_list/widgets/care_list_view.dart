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

import '../../../core/theme/app_colors.dart';
import '../../../models/care_place.dart';
import '../../shared/widgets/care_place_card.dart';

/// What [CareListView] says when there are no places, unless told otherwise.
const String defaultCareListEmptyText =
    'No places were found. Try a nearby larger city.';

/// The places to get care, one [CarePlaceCard] each, or [emptyText] in a
/// card when there are none.
///
/// With a [title], a header goes above them: the title in small brown
/// capitals on the left, and the [city] searched on the right.
class CareListView extends StatelessWidget {
  /// Creates the list of [places].
  const CareListView({
    super.key,
    required this.places,
    required this.onSelect,
    this.selectedId,
    this.emptyText = defaultCareListEmptyText,
    this.title,
    this.city,
  });

  /// The header's title, e.g. "Places nearby"; no header when `null`.
  final String? title;

  /// The city the places are near, shown in the header, if known.
  final String? city;

  /// The places, in the order to show them.
  final List<CarePlace> places;

  /// The picked place's id, or `null` (or empty) when none is picked.
  final String? selectedId;

  /// Called with a place's id when its card is tapped.
  final ValueChanged<String> onSelect;

  /// Shown when [places] is empty.
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final String? title = this.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (title != null) _SectionHeader(title: title, city: city),
        if (places.isEmpty)
          _EmptyCard(text: emptyText)
        else
          for (final CarePlace place in places)
            CarePlaceCard(
              key: ValueKey(place.id),
              place: place,
              selected: place.id == selectedId,
              onSelect: onSelect,
            ),
      ],
    );
  }
}

/// The list's header: [title] on the left, [city] with an arrow on the
/// right.
class _SectionHeader extends StatelessWidget {
  /// Creates the header.
  const _SectionHeader({required this.title, this.city});

  /// The title, shown in capitals.
  final String title;

  /// The city searched, if known.
  final String? city;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String? city = this.city;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 12,
        children: [
          Flexible(
            child: Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: text.labelMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.eyebrow,
                ),
              ),
            ),
          ),
          if (city != null && city.isNotEmpty)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  const Icon(
                    Icons.near_me_outlined,
                    size: 16,
                    color: AppColors.caption,
                  ),
                  Flexible(
                    child: Text(
                      city,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.caption,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A card with [text], shown when there are no places.
class _EmptyCard extends StatelessWidget {
  /// Creates the card.
  const _EmptyCard({required this.text});

  /// What to say, e.g. that nothing was found.
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.travel_explore_rounded, color: AppColors.caption),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
