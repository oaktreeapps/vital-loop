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
import 'package:genui/genui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

/// Logger for this file; warns about bad colors and unknown fonts in a theme.
final Logger _log = Logger('SurfaceTheme');

/// Applies the `theme` from a surface's `createSurface` message to [child].
///
/// genui's built-in components have no style properties; they take their
/// colors, fonts and shapes from the Flutter [Theme]. This widget turns the
/// surface's JSON theme into a [ThemeData], so a screen can be styled from
/// its JSON file:
///
/// ```json
/// "createSurface": {
///   "surfaceId": "...",
///   "catalogId": "...",
///   "theme": {
///     "fontFamily": "Open Sans",
///     "cornerRadius": 20,
///     "colors": {
///       "primary": "#2C4A3E", "onPrimary": "#FFFFFF",
///       "background": "#F4F0EA", "surface": "#FFFFFF",
///       "text": "#1F2A24", "border": "#E8E1D6"
///     },
///     "text": {
///       "h2": {"size": 30, "weight": 700, "color": "#1F2A24", "height": 1.2},
///       "caption": {"size": 14, "weight": 500, "letterSpacing": 0.2}
///     }
///   }
/// }
/// ```
///
/// `text` keys are the Text component's variants (h1–h5, body, caption), plus
/// `chip` for chip labels. `colors.field` fills text fields.
/// `fontFamily` is any Google Fonts family. Every key is optional; a surface
/// without a theme uses the app theme.
class SurfaceTheme extends StatelessWidget {
  /// Wraps [child] in the theme of the surface behind [surfaceContext].
  const SurfaceTheme({
    super.key,
    required this.surfaceContext,
    required this.child,
  });

  /// The surface whose `createSurface` theme is applied. Its definition can
  /// change while the screen streams in, so the theme is rebuilt each time.
  final SurfaceContext surfaceContext;

  /// The surface's rendered content.
  final Widget child;

  /// Rebuilds [child] under the surface's theme whenever the surface
  /// definition changes; with no theme, returns [child] as is.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SurfaceDefinition?>(
      valueListenable: surfaceContext.definition,
      builder: (context, definition, child) {
        final JsonMap? json = definition?.theme;
        if (json == null || json.isEmpty) return child!;

        final ThemeData theme = surfaceThemeData(Theme.of(context), json);
        return Theme(
          data: theme,
          child: ColoredBox(
            color: theme.scaffoldBackgroundColor,
            // Top-level "body" Text uses the ambient DefaultTextStyle, which
            // comes from the Scaffold, not from Theme; restyle it too.
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium,
              child: child!,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Builds the [ThemeData] for a surface theme [json] on top of [base].
///
/// Colors, fonts and text styles missing from [json] keep the value from
/// [base]. When the theme's brightness differs from [base]'s, a fresh theme
/// of that brightness is used as the base instead.
///
/// The component themes genui's components use are always replaced, even
/// when [json] sets none of their keys: flat cards without margins,
/// unelevated buttons, bordered chips, text fields, dividers and the date
/// and time pickers, styled from the theme's colors, `cornerRadius` and
/// `border` color.
ThemeData surfaceThemeData(ThemeData base, JsonMap json) {
  final JsonMap colors = _map(json['colors']);
  final Color? primary = parseHexColor(colors['primary']);
  final Color? onPrimary = parseHexColor(colors['onPrimary']);
  final Color? background = parseHexColor(colors['background']);
  final Color? surface = parseHexColor(colors['surface']);
  final Color? text = parseHexColor(colors['text']);
  final Color? border = parseHexColor(colors['border']);
  final Color? field = parseHexColor(colors['field']);
  final double? radius = _double(json['cornerRadius']);

  // Light or dark comes from the theme itself ("brightness", else its
  // background color), not from the phone's setting: a light palette on a
  // phone in dark mode would otherwise get dark dialogs with dark text.
  final Brightness brightness = switch (json['brightness']) {
    'light' => Brightness.light,
    'dark' => Brightness.dark,
    _ =>
      background == null
          ? base.brightness
          : ThemeData.estimateBrightnessForColor(background),
  };
  // Start fresh when that differs from the app's, so none of the app theme's
  // defaults for the other brightness leak in.
  if (brightness != base.brightness) {
    base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary ?? base.colorScheme.primary,
        brightness: brightness,
      ),
    );
  }

  final ColorScheme scheme =
      (primary == null
              ? base.colorScheme
              : ColorScheme.fromSeed(
                  seedColor: primary,
                  brightness: brightness,
                ))
          .copyWith(
            primary: primary,
            onPrimary: onPrimary,
            surface: surface,
            onSurface: text,
            outline: border,
            outlineVariant: border,
          );

  TextTheme textTheme = base.textTheme.apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );
  if (json['fontFamily'] case final String family) {
    try {
      textTheme = GoogleFonts.getTextTheme(family, textTheme);
    } on Exception catch (e) {
      _log.warning('Unknown font "$family", using the default font: $e');
    }
  }
  textTheme = _applyVariants(textTheme, _map(json['text']));

  final BorderSide? side = border == null ? null : BorderSide(color: border);
  final OutlinedBorder? shape = radius == null
      ? null
      : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: side ?? BorderSide.none,
        );

  return base.copyWith(
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: background ?? base.scaffoldBackgroundColor,
    dividerTheme: DividerThemeData(color: border),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: shape,
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    ),
    chipTheme: _chipTheme(scheme, textTheme, side),
    // DateTimeInput's pickers: the surface color with a primary header and
    // selection, and the theme's corners.
    datePickerTheme: DatePickerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: scheme.primary,
      headerForegroundColor: scheme.onPrimary,
      dividerColor: border,
      shape: _dialogShape(radius),
      todayBorder: BorderSide(color: scheme.primary),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: scheme.surface,
      shape: _dialogShape(radius),
      dialBackgroundColor: field ?? background,
      dialHandColor: scheme.primary,
      dialTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.onSurface,
      ),
      hourMinuteColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : field ?? scheme.surfaceContainerHighest,
      ),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.onSurface,
      ),
      dayPeriodColor: scheme.primary,
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.onSurface,
      ),
      entryModeIconColor: scheme.onSurface,
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: field != null,
      fillColor: field,
      border: _inputBorder(radius, side),
      enabledBorder: _inputBorder(radius, side),
      focusedBorder: _inputBorder(
        radius,
        BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
  );
}

/// Chips (ChoicePicker with `"displayStyle": "chips"`): pills with a border,
/// filled with the primary color when selected.
ChipThemeData _chipTheme(
  ColorScheme scheme,
  TextTheme textTheme,
  BorderSide? side,
) {
  bool selected(Set<WidgetState> states) =>
      states.contains(WidgetState.selected);
  return ChipThemeData(
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    color: WidgetStateProperty.resolveWith(
      (states) => selected(states) ? scheme.primary : scheme.surface,
    ),
    side: WidgetStateBorderSide.resolveWith(
      (states) => selected(states) ? BorderSide.none : side ?? BorderSide.none,
    ),
    checkmarkColor: scheme.onPrimary,
    labelStyle: textTheme.labelLarge?.copyWith(
      color: WidgetStateColor.resolveWith(
        (states) => selected(states) ? scheme.onPrimary : scheme.onSurface,
      ),
    ),
  );
}

/// The shape of the date and time picker dialogs: a bit rounder than the
/// theme's [radius], or the default shape when there is no radius.
ShapeBorder? _dialogShape(double? radius) => radius == null
    ? null
    : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius + 8));

/// A text field border with the theme's corner [radius] and border [side],
/// or `null` (the default border) when the theme sets neither.
InputBorder? _inputBorder(double? radius, BorderSide? side) =>
    radius == null && side == null
    ? null
    : OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 4),
        borderSide: side ?? const BorderSide(),
      );

/// Applies per-variant styles, keyed by the Text component's variant names.
TextTheme _applyVariants(TextTheme theme, JsonMap variants) {
  // The [base] style with the overrides given for [variant], if any.
  TextStyle? style(String variant, TextStyle? base) {
    final JsonMap json = _map(variants[variant]);
    if (json.isEmpty) return base;
    final double? weight = _double(json['weight']);
    return (base ?? const TextStyle()).copyWith(
      fontSize: _double(json['size']),
      fontWeight: weight == null ? null : _fontWeight(weight),
      color: parseHexColor(json['color']),
      height: _double(json['height']),
      letterSpacing: _double(json['letterSpacing']),
    );
  }

  // Same mapping as genui's Text component.
  return theme.copyWith(
    headlineLarge: style('h1', theme.headlineLarge),
    headlineMedium: style('h2', theme.headlineMedium),
    headlineSmall: style('h3', theme.headlineSmall),
    titleLarge: style('h4', theme.titleLarge),
    titleMedium: style('h5', theme.titleMedium),
    bodyMedium: style('body', theme.bodyMedium),
    bodySmall: style('caption', theme.bodySmall),
    // Not a Text variant: chip labels.
    labelLarge: style('chip', theme.labelLarge),
  );
}

/// [value] as a JSON map, or an empty map if it is not a map (e.g. missing).
JsonMap _map(Object? value) =>
    value is Map ? value.cast<String, Object?>() : const {};

/// [value] as a double if it is a number, else `null`.
double? _double(Object? value) => value is num ? value.toDouble() : null;

/// The [FontWeight] closest to a CSS-style [weight] like 400 or 700,
/// limited to w100–w900.
FontWeight _fontWeight(double weight) {
  final int index = ((weight / 100).round() - 1).clamp(0, 8);
  return FontWeight.values[index];
}

/// [color] as `#RRGGBB`, the form [parseHexColor] reads; alpha is dropped.
String formatHexColor(Color color) {
  final String rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16);
  return '#${rgb.padLeft(6, '0').toUpperCase()}';
}

/// Parses `#RRGGBB` or `#AARRGGBB`.
///
/// Returns `null` (and logs a warning for a bad string) when [value] is not
/// a valid color, so callers can fall back to a theme color with `??`.
Color? parseHexColor(Object? value) {
  if (value is! String) return null;
  final String hex = value.replaceFirst('#', '');
  final int? argb = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  if (argb == null || hex.length != 6 && hex.length != 8) {
    _log.warning('Invalid color "$value"; use #RRGGBB or #AARRGGBB');
    return null;
  }
  return Color(argb);
}
