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

/// The place the user picked on the care nearby screen, under the report:
/// a "CARE YOU CHOSE" label and the place's card, with its Directions,
/// Call and Website buttons.
class ChosenCare extends StatelessWidget {
  /// Creates the section for [place].
  const ChosenCare({super.key, required this.place});

  /// The place the user picked.
  final CarePlace place;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Semantics(
            header: true,
            child: Text(
              'CARE YOU CHOSE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.eyebrow,
              ),
            ),
          ),
        ),
        CarePlaceCard(place: place),
      ],
    );
  }
}
