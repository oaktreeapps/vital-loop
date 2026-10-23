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

/// The entry count on a card's icon tile.
class CountBadge extends StatelessWidget {
  /// Creates a badge showing [count].
  const CountBadge(this.count, {super.key});

  /// How many entries were logged today.
  final int count;

  /// Builds the round green badge.
  @override
  Widget build(BuildContext context) {
    // The card's "logged" pill already reads the count to screen readers.
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const ShapeDecoration(
          color: AppColors.logged,
          shape: StadiumBorder(
            side: BorderSide(color: AppColors.surface, width: 2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$count',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
