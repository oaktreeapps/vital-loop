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

import '../../core/theme/app_colors.dart';
import '../common/app_dialog.dart';
import '../common/app_input_decoration.dart';
import '../common/primary_button.dart';

/// Asks where to look for care nearby: a city or area, filled in with
/// [initialCity].
///
/// Closes with the typed city, trimmed, or with `null` when dismissed.
/// Shown by the daily summary's "Find care nearby" button.
class CareCityDialog extends StatefulWidget {
  /// Creates the dialog, starting with [initialCity] in its field.
  const CareCityDialog({super.key, required this.initialCity});

  /// The city in the field when the dialog opens.
  final String initialCity;

  /// Creates the state that holds the typed city.
  @override
  State<CareCityDialog> createState() => _CareCityDialogState();
}

/// Holds the city the user types.
class _CareCityDialogState extends State<CareCityDialog> {
  /// The city in the field, all selected, so typing replaces it.
  late final TextEditingController _cityController =
      TextEditingController(text: widget.initialCity)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.initialCity.length,
        );

  /// Frees the text controller.
  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  /// Closes the dialog with the typed city, if there is one.
  void _search() {
    final String city = _cityController.text.trim();
    if (city.isNotEmpty) Navigator.of(context).pop(city);
  }

  /// The title, what the search finds, the city field and Find care.
  @override
  Widget build(BuildContext context) {
    return AppDialog(
      icon: Icons.location_on_rounded,
      eyebrow: 'Care nearby',
      title: 'Where should we look?',
      body:
          'Enter a city or area. You will see hospitals, clinics and doctors '
          'in or near it that fit what you logged today.',
      action: ValueListenableBuilder<TextEditingValue>(
        // Rebuilds only the button as the city is typed, to turn it on or
        // off.
        valueListenable: _cityController,
        builder: (context, value, _) => PrimaryButton(
          label: 'Find care',
          icon: Icons.search_rounded,
          onPressed: value.text.trim().isEmpty ? null : _search,
        ),
      ),
      children: [
        TextField(
          controller: _cityController,
          autofocus: true,
          autocorrect: false,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          style: appInputTextStyle(),
          cursorColor: AppColors.primary,
          decoration: appInputDecoration(
            hintText: 'City or area',
            prefixIcon: const Icon(
              Icons.location_city_rounded,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
