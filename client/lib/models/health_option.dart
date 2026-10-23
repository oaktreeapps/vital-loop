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

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../flows/medication_flow.dart';
import '../flows/nutrition_flow.dart';
import '../flows/pain_flow.dart';
import '../flows/symptoms_flow.dart';
import '../flows/vitals_flow.dart';
import '../widgets/common/line_icon.dart';
import 'tracking_flow.dart';

// Icon builders for [HealthTrackingOption.icon]. Each one draws the icon in
// the given color and size, so the dashboard can tint it.

/// A bandage icon, for [HealthTrackingOption.pain].
Widget _bandage(Color color, double size) =>
    Icon(CupertinoIcons.bandage, color: color, size: size);

/// A thermometer icon, for [HealthTrackingOption.symptoms].
Widget _thermometer(Color color, double size) =>
    Icon(CupertinoIcons.thermometer, color: color, size: size);

/// A heart with a pulse line, for [HealthTrackingOption.vitals].
Widget _heartPulse(Color color, double size) =>
    LineIcon(LineIconShape.heartPulse, color: color, size: size);

/// A pill capsule, for [HealthTrackingOption.medications].
Widget _pill(Color color, double size) =>
    LineIcon(LineIconShape.pill, color: color, size: size);

/// A bowl of soup, for [HealthTrackingOption.foodNutrition].
Widget _soupBowl(Color color, double size) =>
    LineIcon(LineIconShape.soupBowl, color: color, size: size);

/// The health tracking options shown on the dashboard.
///
/// Each value is one tile on the dashboard: its text, its icon and colors,
/// and the [TrackingFlow] that opens when the user taps it.
enum HealthTrackingOption {
  /// Log where it hurts, how much, and what set it off.
  pain(
    title: 'Pain',
    subtitle: 'Location, intensity and triggers',
    icon: _bandage,
    color: AppColors.red,
    tint: AppColors.redTint,
  ),

  /// Log how the user feels, like a headache or nausea.
  symptoms(
    title: 'Symptoms',
    subtitle: 'What you’re feeling right now',
    icon: _thermometer,
    color: AppColors.amber,
    tint: AppColors.amberTint,
  ),

  /// Log body measurements like blood pressure and heart rate.
  vitals(
    title: 'Vitals',
    subtitle: 'Blood pressure, heart rate, temperature',
    icon: _heartPulse,
    color: AppColors.rose,
    tint: AppColors.roseTint,
  ),

  /// Log a medicine dose that was taken.
  medications(
    title: 'Medications',
    subtitle: 'Doses taken and schedules',
    icon: _pill,
    color: AppColors.indigo,
    tint: AppColors.indigoTint,
  ),

  /// Log a meal or a snack.
  foodNutrition(
    title: 'Food & nutrition',
    subtitle: 'Meals, portions and notes',
    icon: _soupBowl,
    color: AppColors.green,
    tint: AppColors.greenTint,
  );

  /// Sets the tile's text, icon and colors.
  const HealthTrackingOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tint,
  });

  /// The tile's heading, e.g. "Pain".
  final String title;

  /// A short line under [title] that says what the user can log.
  final String subtitle;

  /// Builds the option's line icon in `color` at `size`.
  final Widget Function(Color color, double size) icon;

  /// Icon color.
  final Color color;

  /// Background of the icon tile.
  final Color tint;

  /// The option's tracking flow.
  TrackingFlow get flow => switch (this) {
    HealthTrackingOption.pain => painFlow,
    HealthTrackingOption.symptoms => symptomsFlow,
    HealthTrackingOption.vitals => vitalsFlow,
    HealthTrackingOption.medications => medicationFlow,
    HealthTrackingOption.foodNutrition => nutritionFlow,
  };
}
