// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

class _TabsWidget extends StatefulWidget {
  const _TabsWidget({
    required this.tabs,
    required this.children,
    required this.itemContext,
    required this.activeTab,
    this.initialTab = 0,
    required this.onTabChanged,
  });

  /// Each tab's JSON: its `title` and the id of its `child`.
  final List<JsonMap> tabs;

  /// Each tab's child component, in the order of [tabs].
  final List<ComponentNode<ComponentImplementation>?> children;
  final CatalogItemContext itemContext;
  final int? activeTab;
  final int initialTab;
  final ValueChanged<int> onTabChanged;

  @override
  State<_TabsWidget> createState() => _TabsWidgetState();
}

class _TabsWidgetState extends State<_TabsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final int initialIndex = (widget.activeTab ?? widget.initialTab).clamp(
      0,
      widget.tabs.length - 1,
    );
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void didUpdateWidget(_TabsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabController.dispose();
      final int initialIndex = (widget.activeTab ?? widget.initialTab).clamp(
        0,
        widget.tabs.length - 1,
      );
      _tabController = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: initialIndex,
      );
      _tabController.addListener(_handleTabSelection);
    } else if (widget.activeTab != oldWidget.activeTab) {
      _handleExternalChange();
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      widget.onTabChanged(_tabController.index);
    }
  }

  void _handleExternalChange() {
    final int? newIndex = widget.activeTab;
    if (newIndex != null &&
        newIndex >= 0 &&
        newIndex < widget.tabs.length &&
        newIndex != _tabController.index) {
      _tabController.animateTo(newIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabController,
          tabs: widget.tabs.map((tabItem) {
            final Object? labelRef = tabItem['label'] ?? tabItem['title'];
            return BoundString(
              dataContext: widget.itemContext.dataContext,
              value: labelRef,
              builder: (context, label) {
                return Tab(text: label ?? '');
              },
            );
          }).toList(),
        ),
        SizedBox(
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              final int index = _tabController.index;
              return IndexedStack(
                index: index,
                sizing: StackFit.loose,
                children: [
                  for (final ComponentNode<ComponentImplementation>? child
                      in widget.children)
                    child == null
                        ? const SizedBox.shrink()
                        : widget.itemContext.buildChild(child),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A Material Design tab layout.
///
/// This widget displays a [TabBar] and a view area to allow navigation
/// between different child components. Each tab in `tabs` has a label and
/// a corresponding child component ID to display when selected.
///
/// ## Parameters:
///
/// - `tabs`: A list of tabs to display, each with a `label` and a `content`
///   widget ID.
/// - `activeTab`: (Optional) Binding to the current tab index.
/// A tab bar above the child component of the selected tab.
///
/// Each of `tabs` has a `title` and a `child`. `activeTab`, the index of the
/// selected tab, may be bound to the data model; picking a tab writes it.
final CatalogItem tabs = CatalogItem(
  name: 'Tabs',
  description: 'A tab layout to navigate between different child components.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Tabs', (properties, _) {
    properties['activeTab'] = {
      r'$ref': r'common_types.json#/$defs/DynamicNumber',
    };
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    final Object? activeTabRef = data['activeTab'];
    final path = activeTabRef is Map && activeTabRef['@path'] is String
        ? activeTabRef['@path'] as String
        : '${itemContext.id}.activeTab';
    final List<JsonMap> tabItems = [
      if (data['tabs'] case final List<Object?> items)
        for (final Object? item in items)
          if (item is Map) item.cast<String, Object?>(),
    ];
    // The tabs' children as mounted nodes, in the same order.
    final List<ComponentNode<ComponentImplementation>?> children = [
      for (final Object? item in itemContext.props.list('tabs'))
        if (item is Map)
          switch (item['child']) {
            final ComponentNode<ComponentImplementation> child => child,
            _ => null,
          },
    ];

    return BoundNumber(
      dataContext: itemContext.dataContext,
      value: {'@path': path},
      builder: (context, value) => _TabsWidget(
        tabs: tabItems,
        children: children,
        itemContext: itemContext,
        activeTab: value?.toInt(),
        initialTab: activeTabRef is num ? activeTabRef.toInt() : 0,
        onTabChanged: (newIndex) => itemContext.dataContext.set(path, newIndex),
      ),
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "Tabs",
          "activeTab": {
            "@path": "/currentTab"
          },
          "tabs": [
            {
              "title": "Overview",
              "child": "text1"
            },
            {
              "title": "Details",
              "child": "text2"
            }
          ]
        },
        {
          "id": "text1",
          "component": "Text",
          "text": "This is a short summary of the item."
        },
        {
          "id": "text2",
          "component": "Text",
          "text": "This is a much longer, more detailed description."
        }
      ]
    ''',
  ],
);
