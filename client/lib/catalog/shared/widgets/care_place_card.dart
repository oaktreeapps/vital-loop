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
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/care_place.dart';
import '../open_link.dart';
import 'round_icon_button.dart';

/// One place to get care: its icon, name, rating and kind, why it fits what
/// the user logged, its address, and a Directions button with round Call and
/// Website buttons.
///
/// Used by the CareList and the PdfReport. In the list, tapping the card
/// picks the place ([onSelect]); a picked card has a green outline and its
/// pin is shown on the map. Without [onSelect] the card can't be tapped.
class CarePlaceCard extends StatelessWidget {
  /// Creates the card for [place].
  const CarePlaceCard({
    super.key,
    required this.place,
    this.selected = false,
    this.onSelect,
  });

  /// The place to show.
  final CarePlace place;

  /// Whether this place is the picked one.
  final bool selected;

  /// Called with the place's id when the card is tapped; `null` when the
  /// card isn't for picking.
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: selected
              ? const BorderSide(color: AppColors.primary, width: 1.5)
              : const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelect == null ? null : () => onSelect?.call(place.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                _Header(place: place),
                if (place.reason case final String reason)
                  _ReasonQuote(reason: reason),
                if (place.address.isNotEmpty) _Address(address: place.address),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _Actions(place: place),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The round icon, the name, and the rating and kind chips.
class _Header extends StatelessWidget {
  /// Creates the header for [place].
  const _Header({required this.place});

  /// The place whose header to show.
  final CarePlace place;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final double? rating = place.rating;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        _KindIcon(type: place.type),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                place.name,
                softWrap: true,
                textWidthBasis: TextWidthBasis.parent,
                style: text.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.text,
                ),
              ),
              if (rating != null || place.kind.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (rating != null)
                      _RatingChip(rating: rating, count: place.ratingCount),
                    if (place.kind.isNotEmpty) _KindChip(kind: place.kind),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A small pill on the off-white field color, around [child].
class _Chip extends StatelessWidget {
  /// Creates the pill.
  const _Chip({required this.child});

  /// What the pill shows.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: child,
      ),
    );
  }
}

/// The Google rating, e.g. "★ 4.9 (331)".
class _RatingChip extends StatelessWidget {
  /// Creates the chip for [rating] by [count] people.
  const _RatingChip({required this.rating, required this.count});

  /// The average rating, 1 to 5.
  final double rating;

  /// How many people rated the place, if known.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.caption);
    final String value = rating.toStringAsFixed(1);
    return Semantics(
      label:
          'Rated $value out of 5'
          '${count == null ? '' : ' by $count people'}',
      excludeSemantics: true,
      child: _Chip(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            const Icon(Icons.star_rounded, size: 14, color: AppColors.starGold),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (count != null) TextSpan(text: ' ($count)'),
                ],
              ),
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

/// What the place is, e.g. "Orthopedic surgeon".
class _KindChip extends StatelessWidget {
  /// Creates the chip for [kind].
  const _KindChip({required this.kind});

  /// The place's kind, in words.
  final String kind;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      child: Text(
        kind,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

/// Why the place fits what the user logged, set off by a brown rule.
class _ReasonQuote extends StatelessWidget {
  /// Creates the quote of [reason].
  const _ReasonQuote({required this.reason});

  /// The reason, written by the LLM.
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.eyebrow, width: 2)),
      ),
      child: Text(
        reason,
        softWrap: true,
        textWidthBasis: TextWidthBasis.parent,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.5,
          color: AppColors.text,
        ),
      ),
    );
  }
}

/// A pin and the street address.
class _Address extends StatelessWidget {
  /// Creates the line for [address].
  const _Address({required this.address});

  /// The street address.
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.location_on_outlined,
            size: 18,
            color: AppColors.caption,
          ),
        ),
        Expanded(
          child: Text(
            address,
            softWrap: true,
            textWidthBasis: TextWidthBasis.parent,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.45,
              color: AppColors.caption,
            ),
          ),
        ),
      ],
    );
  }
}

/// A Directions pill, then round Call and Website buttons when the place
/// has a phone or a website.
class _Actions extends StatelessWidget {
  /// Creates the buttons for [place].
  const _Actions({required this.place});

  /// The place the buttons open.
  final CarePlace place;

  /// Opens [uri] after a light tap feedback; [what] names it if it fails.
  void _open(BuildContext context, Uri uri, String what) {
    HapticFeedback.lightImpact();
    openLink(context, uri, what);
  }

  @override
  Widget build(BuildContext context) {
    final Uri? phoneUrl = place.phoneUrl;
    final Uri? website = place.website;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _open(context, place.directionsUrl, 'directions'),
            icon: const Icon(Icons.directions_rounded, size: 18),
            label: const Text('Directions'),
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
              shape: const WidgetStatePropertyAll(StadiumBorder()),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              foregroundColor: const WidgetStatePropertyAll(
                AppColors.onPrimary,
              ),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.pressed)
                    ? AppColors.primary.withValues(alpha: 0.85)
                    : AppColors.primary,
              ),
            ),
          ),
        ),
        if (phoneUrl != null)
          RoundIconButton(
            icon: Icons.call_outlined,
            tooltip: 'Call',
            size: 44,
            onPressed: () => _open(context, phoneUrl, 'the phone app'),
          ),
        if (website != null)
          RoundIconButton(
            icon: Icons.language_outlined,
            tooltip: 'Website',
            size: 44,
            onPressed: () => _open(context, website, 'the website'),
          ),
      ],
    );
  }
}

/// A dark green circle with a white icon for the place's Google [type].
class _KindIcon extends StatelessWidget {
  /// Creates the circle for [type], e.g. "hospital".
  const _KindIcon({required this.type});

  /// Google's place type.
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(carePlaceIcon(type), color: AppColors.onPrimary, size: 20),
    );
  }
}

/// The icon for a place of Google's [type]: a cross for hospitals, a shield
/// for doctors and anything else without its own icon.
IconData carePlaceIcon(String type) => switch (type) {
  'hospital' || 'general_hospital' => Icons.local_hospital_rounded,
  'pharmacy' || 'drugstore' => Icons.local_pharmacy_rounded,
  'dentist' || 'dental_clinic' => Icons.medical_services_rounded,
  'physiotherapist' || 'chiropractor' => Icons.accessibility_new_rounded,
  'medical_lab' => Icons.biotech_rounded,
  _ => Icons.health_and_safety_rounded,
};
