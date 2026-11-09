// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

final Logger _log = Logger('Image');

/// An image from a network URL or an asset path, sized by its `variant`
/// (e.g. "icon", "avatar", "mediumFeature", "header").
final CatalogItem image = CatalogItem(
  name: 'Image',
  description:
      'A UI element for displaying image data from a URL or asset path.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Image', (properties, _) {
    properties['description'] = {
      r'$ref': r'common_types.json#/$defs/DynamicString',
    };
    (properties['fit']! as JsonMap)['enum'] = [
      for (final BoxFit fit in BoxFit.values) fit.name,
    ];
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final String? variant = stringOrNull(data['variant']);
    final BoxFit? fit = BoxFit.values.asNameMap()[data['fit']];
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['url'],
      builder: (context, value) {
        if (value == null || value.isEmpty) {
          _log.warning(
            'Image widget created with no URL at path: '
            '${itemContext.dataContext.path}',
          );
          return const SizedBox.shrink();
        }

        Widget child;
        if (value.startsWith('http')) {
          child = Image.network(
            value,
            fit: fit,
            frameBuilder:
                (
                  BuildContext context,
                  Widget child,
                  int? frame,
                  bool wasSynchronouslyLoaded,
                ) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
            loadingBuilder:
                (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const Icon(Icons.broken_image);
                },
          );
        } else {
          child = Image.asset(
            value,
            fit: fit,
            frameBuilder:
                (
                  BuildContext context,
                  Widget child,
                  int? frame,
                  bool wasSynchronouslyLoaded,
                ) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const Icon(Icons.broken_image);
                },
          );
        }

        if (variant == 'avatar') {
          child = CircleAvatar(child: child);
        }

        if (variant == 'header') {
          return _describe(
            itemContext,
            data['description'],
            SizedBox(width: double.infinity, child: child),
          );
        }

        final double size = switch (variant) {
          'icon' || 'avatar' => 32.0,
          'smallFeature' => 50.0,
          'mediumFeature' => 150.0,
          'largeFeature' => 400.0,
          _ => 150.0,
        };

        return _describe(
          itemContext,
          data['description'],
          SizedBox(width: size, height: size, child: child),
        );
      },
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "Image",
          "url": {
            "@path": "/imageUrl"
          },
          "description": "A bicycle leaning against a wall",
          "variant": "mediumFeature"
        }
      ]
    ''',
  ],
);

/// [child] with the image's `description` as its screen-reader label.
Widget _describe(
  CatalogItemContext itemContext,
  Object? description,
  Widget child,
) {
  if (description == null) return child;
  return BoundString(
    dataContext: itemContext.dataContext,
    value: description,
    builder: (context, label) => label == null || label.isEmpty
        ? child
        : Semantics(label: label, image: true, child: child),
  );
}
