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

import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../catalog/shared/catalog_item.dart';
import '../catalog/vitalloop_catalog.dart';
import '../core/theme/surface_markdown.dart';
import '../flows/daily_summary_flow.dart';
import '../models/health_option.dart';
import '../models/tracking_flow.dart';
import '../services/genui_session.dart';
import '../widgets/component_preview/component_card.dart';
import '../widgets/component_preview/json_block.dart';
import '../widgets/component_preview/json_sheet.dart';

/// Logger for this screen's messages.
final Logger _log = Logger('CatalogScreen');

/// The basic components, which every flow's screens can use.
final List<CatalogItem> defaultCatalogItems = basicCatalogItems;

/// The app's own components (`lib/catalog/`), each once, in the order the
/// flows list them: every dashboard flow, then the daily summary.
final List<CatalogItem> customCatalogItems = () {
  final List<TrackingFlow> flows = [
    for (final HealthTrackingOption option in HealthTrackingOption.values)
      option.flow,
    dailySummaryFlow(const []),
  ];
  final names = <String>{};
  return [
    for (final TrackingFlow flow in flows)
      for (final CatalogItem item in flow.customItems)
        if (names.add(item.name)) item,
  ];
}();

/// Shows every component the flows' screens can use, in two tabs: Default
/// (the basic components) and Custom (the app's own). Each has a live
/// preview rendered from its example A2UI JSON, the JSON itself, and the
/// schema the backend must follow.
///
/// Previews go through the same MessageProcessor path as backend responses,
/// so what renders here is what the backend would get by sending that JSON.
class CatalogScreen extends StatefulWidget {
  /// Creates the catalog screen.
  const CatalogScreen({super.key});

  /// Creates the state that renders the previews.
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

/// State of [CatalogScreen]: owns the [MessageProcessor] that keeps one
/// preview surface per catalog item.
class _CatalogScreenState extends State<CatalogScreen> {
  /// Keeps the previews' surfaces, with the basic and every custom component.
  final MessageProcessor<ComponentImplementation> _processor =
      MessageProcessor<ComponentImplementation>(
        catalogs: [vitalLoopCatalog(customItems: customCatalogItems)],
        reportErrorsOnly: true,
      );

  /// Listens for taps in the previews, see [_showAction].
  late final Subscription _actionSub;

  /// Logs a preview the processor can't use.
  late final Subscription _errorSub;

  /// Component name → the example components rendered as its preview.
  final Map<String, List<JsonMap>> _examples = {};

  /// Creates one preview surface for every catalog item that has example
  /// data, by sending its example JSON to [_processor] as A2UI messages.
  @override
  void initState() {
    super.initState();
    _errorSub = _processor.model.onError.subscribe(
      (error) => _log.warning('Preview error ${error.code}: ${error.message}'),
    );
    for (final CatalogItem item in [
      ...defaultCatalogItems,
      ...customCatalogItems,
    ]) {
      if (item.exampleData.isEmpty) continue;
      final List<JsonMap> components = [
        for (final Object? component
            in jsonDecode(item.exampleData.first()) as List)
          (component! as Map).cast<String, Object?>(),
      ];
      _examples[item.name] = components;
      _log.info('Render example for ${item.name} → MessageProcessor');
      _processor.processMessages([
        {
          'version': a2uiVersion,
          'createSurface': {
            'surfaceId': _surfaceId(item),
            'catalogId': vitalLoopCatalogId,
          },
        },
        {
          'version': a2uiVersion,
          'updateComponents': {
            'surfaceId': _surfaceId(item),
            'components': components,
          },
        },
      ]);
    }
    // A tap in a preview produces the exact event a backend would receive.
    _actionSub = _processor.model.onAction.subscribe(_showAction);
  }

  /// The id of the preview surface for [item], e.g. `catalog_Button`.
  String _surfaceId(CatalogItem item) => 'catalog_${item.name}';

  /// Shows the action from a tap in a preview in a bottom sheet, so you can
  /// see what the backend would receive.
  void _showAction(A2uiRendererAction rendererAction) {
    if (!mounted) return;
    final UserAction action = userActionFrom(rendererAction);
    _log.info('Preview action → would be sent to backend: ${action.name}');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => JsonSheet(
        title: 'Sent to the backend',
        json: prettyJson.convert({
          'name': action.name,
          'context': action.context,
        }),
      ),
    );
  }

  /// Stops listening for taps and closes the processor.
  @override
  void dispose() {
    _actionSub.unsubscribe();
    _errorSub.unsubscribe();
    _processor.dispose();
    super.dispose();
  }

  /// Builds the Default and Custom tabs.
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Catalog'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Default (${defaultCatalogItems.length})'),
              Tab(text: 'Custom (${customCatalogItems.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _componentList(
              intro:
                  'These components come with A2UI and every flow can use '
                  'them. The backend composes screens from them by sending '
                  'A2UI JSON that follows each schema. Tap a button in a '
                  'preview to see the event the backend receives.',
              items: defaultCatalogItems,
            ),
            _componentList(
              intro:
                  'These components are made for VitalLoop (lib/catalog/). '
                  'A flow lists the ones its screens use, on top of the '
                  'default ones. Tap a button in a preview to see the event '
                  'the backend receives.',
              items: customCatalogItems,
            ),
          ],
        ),
      ),
    );
  }

  /// A tab's short [intro] text and one [ComponentCard] per item in [items].
  Widget _componentList({
    required String intro,
    required List<CatalogItem> items,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(intro, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        for (final CatalogItem item in items)
          if (_examples[item.name] case final List<JsonMap> example)
            if (_processor.model.getSurface(_surfaceId(item))
                case final SurfaceModel<ComponentImplementation> surface)
              ComponentCard(
                item: item,
                example: example,
                preview: SurfaceView(surface: surface),
              ),
      ],
    );
  }
}
