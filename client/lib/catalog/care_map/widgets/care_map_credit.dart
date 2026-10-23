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
import '../../shared/open_link.dart';

/// OpenStreetMap's copyright page, which the credit opens.
final Uri openStreetMapCopyright = Uri.parse(
  'https://www.openstreetmap.org/copyright',
);

/// The map's credit, "© OpenStreetMap contributors", at its bottom right,
/// as OpenStreetMap asks. Tapping it opens their copyright page.
///
/// Plain text that wraps, so it fits any width and text size; flutter_map's
/// own credit is one row that can't.
class CareMapCredit extends StatelessWidget {
  /// Creates the credit.
  const CareMapCredit({super.key});

  /// Builds the credit on a light strip in the map's corner.
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: () => openLink(context, openStreetMapCopyright, 'OpenStreetMap'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: AppColors.surface.withValues(alpha: 0.85),
          child: const Text(
            '© OpenStreetMap contributors',
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
