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

/// Shown instead of the map when there are no places to pin: a note and a
/// button that opens [searchUrl] in Google Maps.
class CareMapFallback extends StatelessWidget {
  /// Creates the fallback; [searchUrl] shows the places on Google Maps.
  const CareMapFallback({
    super.key,
    required this.searchUrl,
    required this.message,
  });

  /// A Google Maps link for the area or the places.
  final Uri searchUrl;

  /// The note above the button.
  final String message;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.map_outlined, size: 32, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => openLink(context, searchUrl, 'Google Maps'),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open in Google Maps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size.fromHeight(44),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
