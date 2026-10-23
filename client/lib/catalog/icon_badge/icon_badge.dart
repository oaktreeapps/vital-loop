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
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../core/theme/surface_theme.dart';
import '../shared/data_binding.dart';

/// Material icons an `IconBadge` can show, by name.
///
/// genui's built-in `Icon` only knows a small fixed set (no sun, moon, …).
/// Add entries here to make more icons available to the JSON screens.
const Map<String, IconData> iconBadgeIcons = {
  'sunrise': Icons.wb_twilight,
  'sun': Icons.wb_sunny_outlined,
  'moon': Icons.dark_mode_outlined,
  'bedtime': Icons.bedtime_outlined,
  'cookie': Icons.cookie_outlined,
  'leaf': Icons.eco_outlined,
  'restaurant': Icons.restaurant_outlined,
  'medication': Icons.medication_outlined,
  'breakfast': Icons.breakfast_dining_outlined,
  'lunch': Icons.lunch_dining_outlined,
  'dinner': Icons.dinner_dining_outlined,
  'coffee': Icons.local_cafe_outlined,
  'drink': Icons.local_drink_outlined,
  'water': Icons.water_drop_outlined,
  'schedule': Icons.schedule,
  'sick': Icons.sick_outlined,
  'mood': Icons.mood,
  'note': Icons.edit_note,
  'lightbulb': Icons.lightbulb_outline,
  'info': Icons.info_outline,
  'check': Icons.check_circle_outline,
  'heart': Icons.favorite_border,
  'heartPulse': Icons.monitor_heart_outlined,
  'thermometer': Icons.device_thermostat,
  'bloodDrop': Icons.bloodtype_outlined,
  'gauge': Icons.speed,
  'body': Icons.accessibility_new,
  'location': Icons.location_on_outlined,
};

/// The JSON properties an `IconBadge` takes, as the backend sees them.
final _schema = S.object(
  description:
      'An icon in a tinted rounded square, e.g. to illustrate a choice. '
      'With a label, a tinted pill with the icon and the label instead, '
      'e.g. to tag a screen with an earlier answer.',
  properties: {
    'name': A2uiSchemas.stringReference(
      description: 'The icon to show.',
      enumValues: iconBadgeIcons.keys.toList(),
    ),
    'label': A2uiSchemas.stringReference(
      description: 'Text next to the icon; turns the badge into a pill.',
    ),
    'color': A2uiSchemas.stringReference(
      description: 'Icon and label color, "#RRGGBB".',
    ),
    'background': S.string(description: 'Fill color, "#RRGGBB".'),
    'border': S.string(description: 'A 1px border in this color, "#RRGGBB".'),
    'shape': S.string(
      description:
          'The badge without a label: a rounded square (default) '
          'or a circle.',
      enumValues: ['square', 'circle'],
    ),
    'size': S.number(
      description:
          'Width and height of the square (default 48), or the icon size '
          'of a pill (default 18).',
    ),
  },
  required: ['name'],
);

/// Shows one of [iconBadgeIcons] in a rounded square, or with a `label` in a
/// pill.
///
/// Properties: `name` (required, a key of [iconBadgeIcons]), `label`,
/// `color` and `background` ("#RRGGBB"; they default to the theme's primary
/// colors), `border` ("#RRGGBB", none by default), `shape` ("square" or
/// "circle", for a badge without a label) and `size`. `name`, `label` and
/// `color` may be data-model bindings. The badge only shows things; it
/// writes nothing to the data model. An unknown `name` shows a question-mark
/// icon.
///
/// ```json
/// {"id": "icon", "component": "IconBadge", "name": "sun",
///  "color": "#9A7A1C", "background": "#F5EDC4", "size": 48}
/// {"id": "tag", "component": "IconBadge", "name": "sun", "label": "Lunch",
///  "color": "#6B5412", "background": "#F5EDC4"}
/// {"id": "entry", "component": "IconBadge", "name": "sick",
///  "color": {"path": "color"}, "background": "#FFFFFF",
///  "border": "#E8E1D6", "shape": "circle", "size": 40}
/// ```
final CatalogItem iconBadge = CatalogItem(
  name: 'IconBadge',
  dataSchema: _schema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final ColorScheme scheme = Theme.of(itemContext.buildContext).colorScheme;
    final Color background =
        parseHexColor(data['background']) ?? scheme.primaryContainer;
    final Color? borderColor = parseHexColor(data['border']);
    final BorderSide side = borderColor == null
        ? BorderSide.none
        : BorderSide(color: borderColor);
    final double? size = numberOrNull(data['size'])?.toDouble();

    // Builds the square (or round) badge, or the pill when there is a label.
    Widget badge(String? name, String? label, Color color) {
      final IconData icon = iconBadgeIcons[name] ?? Icons.help_outline;
      if (label == null) {
        final double length = size ?? 48;
        return Container(
          width: length,
          height: length,
          decoration: ShapeDecoration(
            color: background,
            shape: data['shape'] == 'circle'
                ? CircleBorder(side: side)
                : RoundedRectangleBorder(
                    side: side,
                    borderRadius: BorderRadius.circular(length / 4),
                  ),
          ),
          child: Icon(icon, color: color, size: length / 2),
        );
      }
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 14, 6),
        decoration: ShapeDecoration(
          color: background,
          shape: StadiumBorder(side: side),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(icon, color: color, size: size ?? 18),
            Text(
              label,
              style: Theme.of(itemContext.buildContext).textTheme.labelLarge
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    // Keep its own size inside a stretched Column.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      heightFactor: 1,
      child: _bound(
        itemContext,
        data['color'],
        (colorText) => _bound(
          itemContext,
          data['name'],
          (name) => _bound(
            itemContext,
            data['label'],
            (label) => badge(
              name,
              data['label'] == null ? null : label ?? '',
              parseHexColor(colorText) ?? scheme.primary,
            ),
          ),
        ),
      ),
    );
  },
  exampleData: [
    () => '''
      [
        {"id": "root", "component": "Column", "children": ["icons", "tag"]},
        {"id": "icons", "component": "Row", "children": ["a", "b", "c", "d"]},
        {"id": "tag", "component": "IconBadge", "name": "sun", "label": "Lunch", "color": "#6B5412", "background": "#F5EDC4"},
        {"id": "a", "component": "IconBadge", "name": "sunrise", "color": "#C0662B", "background": "#FBE3D2"},
        {"id": "b", "component": "IconBadge", "name": "sun", "color": "#9A7A1C", "background": "#F5EDC4"},
        {"id": "c", "component": "IconBadge", "name": "moon", "color": "#3E4A8A", "background": "#E3E3F3"},
        {"id": "d", "component": "IconBadge", "name": "cookie", "color": "#3F6B4A", "background": "#E2EDE1"}
      ]
    ''',
  ],
);

/// Builds [builder] with the text of [value], a literal or a data-model
/// binding, and rebuilds it when a bound value changes. A missing [value]
/// gives `null`.
Widget _bound(
  CatalogItemContext itemContext,
  Object? value,
  Widget Function(String? text) builder,
) => value == null
    ? builder(null)
    : BoundString(
        dataContext: itemContext.dataContext,
        value: value,
        builder: (context, text) => builder(text),
      );
