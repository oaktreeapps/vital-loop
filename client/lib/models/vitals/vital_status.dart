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

/// Where a reading falls in the general adult ranges. A guide, not a
/// diagnosis.
///
/// Shown as the status chip on each vital sign's card.
enum VitalStatus {
  /// Below the usual range, shown in blue.
  low('Low', AppColors.indigo, AppColors.indigoTint),

  /// Inside the usual range, shown in green.
  normal('Normal', AppColors.green, AppColors.greenTint),

  /// A bit above the usual range, shown in amber.
  elevated('Elevated', AppColors.amber, AppColors.amberTint),

  /// Well above the usual range, shown in red.
  high('High', AppColors.red, AppColors.redTint);

  /// Sets the pill's text and colors.
  const VitalStatus(this.label, this.color, this.background);

  /// The pill's text, e.g. "Normal".
  final String label;

  /// The pill's text color.
  final Color color;

  /// The pill's fill color.
  final Color background;
}
