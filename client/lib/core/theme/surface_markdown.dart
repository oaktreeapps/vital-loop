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

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Draws [surface] with its Text components rendered as Markdown in the
/// surface theme's text styles.
///
/// The A2UI v1.0 basic Text has two variants, `body` and `caption`. A
/// heading is body text written as a Markdown heading (`## Log your
/// vitals`), and a2ui_flutter hands every body Text to the [A2uiMarkdown]
/// above it. This widget is that hook: it gives the headings the theme's
/// styles (see `surface_theme.dart`: `#` is `h1`, ... `#####` is `h5`), so a
/// screen's JSON theme decides their size, weight, color and spacing.
class SurfaceView extends StatelessWidget {
  /// Draws [surface].
  const SurfaceView({super.key, required this.surface});

  /// The surface to draw.
  final SurfaceModel<ComponentImplementation> surface;

  @override
  Widget build(BuildContext context) => A2uiMarkdown(
    builder: surfaceMarkdown,
    child: A2uiSurface(surface: surface),
  );
}

/// The space above and below a heading of each level, `h1` first.
const List<double> _headingPadding = [20, 16, 12, 8, 4, 4];

/// Renders one Text's [markdown], with [style] as its body style and the
/// ambient theme's heading styles: `#` is `headlineLarge` (h1), `##`
/// `headlineMedium` (h2), `###` `headlineSmall` (h3), `####` `titleLarge`
/// (h4), and `#####` `titleMedium` (h5).
Widget surfaceMarkdown(BuildContext context, String markdown, TextStyle style) {
  final ThemeData theme = Theme.of(context);
  final TextTheme text = theme.textTheme;
  EdgeInsets padding(int level) =>
      EdgeInsets.symmetric(vertical: _headingPadding[level - 1]);
  return MarkdownBody(
    data: markdown,
    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: style,
      h1: text.headlineLarge,
      h1Padding: padding(1),
      h2: text.headlineMedium,
      h2Padding: padding(2),
      h3: text.headlineSmall,
      h3Padding: padding(3),
      h4: text.titleLarge,
      h4Padding: padding(4),
      h5: text.titleMedium,
      h5Padding: padding(5),
      h6: text.titleMedium,
      h6Padding: padding(6),
    ),
  );
}
