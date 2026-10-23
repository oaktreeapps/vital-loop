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

import '../../core/theme/app_colors.dart';
import '../../models/health_option.dart';
import 'count_badge.dart';
import 'logged_pill.dart';

/// A card for one tracking option: its icon, title and subtitle, and a
/// chevron. Options with entries today get a green border, a count badge and
/// a "logged" pill.
class OptionCard extends StatelessWidget {
  /// Creates a card for [option].
  const OptionCard({
    super.key,
    required this.option,
    required this.logged,
    required this.onTap,
  });

  /// The tracking option shown on this card.
  final HealthTrackingOption option;

  /// How many entries of this option are in today's log.
  final int logged;

  /// Called when the user taps the card.
  final VoidCallback onTap;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: logged > 0
            ? const BorderSide(color: AppColors.logged, width: 1.5)
            : const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: option.tint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: option.icon(option.color, 26)),
                  ),
                  if (logged > 0)
                    Positioned(top: -6, right: -6, child: CountBadge(logged)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          option.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        if (logged > 0) LoggedPill(logged),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      option.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.5,
                        height: 1.35,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.chevronFill,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
