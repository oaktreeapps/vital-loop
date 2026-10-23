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

// Widget test for the component catalog screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:vitalloop/screens/catalog_screen.dart';

import '../support/test_utils.dart';

void main() {
  setUpTestEnvironment();

  /// Opens the catalog on a screen wide enough for every preview (800
  /// wide): with the wide test font, some previews (genui's AudioPlayer, the
  /// vital inputs, the map's credit line) need more width than a phone has.
  Future<void> openCatalog(WidgetTester tester) async {
    useLargeScreen(tester, size: const Size(2000, 3200));
    await tester.pumpWidget(const MaterialApp(home: CatalogScreen()));
    await settle(tester);
  }

  /// Scrolls the open tab to each of [items] and checks its card is there.
  Future<void> expectCards(WidgetTester tester, List<CatalogItem> items) async {
    final Finder page = find.byType(Scrollable).last;
    for (final item in items) {
      await tester.scrollUntilVisible(
        find.text(item.name),
        300,
        scrollable: page,
      );
      expect(find.text(item.name), findsOneWidget, reason: item.name);
    }
  }

  test('every component has example data, so each tab shows them all', () {
    for (final CatalogItem item in [
      ...defaultCatalogItems,
      ...customCatalogItems,
    ]) {
      expect(item.exampleData, isNotEmpty, reason: item.name);
    }
  });

  test('the custom tab lists every flow\'s components once', () {
    final List<String> names = [
      for (final CatalogItem item in customCatalogItems) item.name,
    ];
    expect(names.toSet(), hasLength(names.length));
    expect(
      names,
      containsAll([
        'IconBadge',
        'BodyMapPicker',
        'SeverityInput',
        'BloodPressureInput',
        'HeartRateInput',
        'TemperatureInput',
        'BloodSugarInput',
        'PdfReport',
        'CareMap',
        'CareList',
      ]),
    );
  });

  testWidgets('the Default tab previews genui\'s built-in components', (
    tester,
  ) async {
    await openCatalog(tester);
    expect(
      find.text('Default (${defaultCatalogItems.length})'),
      findsOneWidget,
    );
    await expectCards(tester, defaultCatalogItems);
    expect(find.text('BodyMapPicker'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Custom tab previews the app\'s own components', (
    tester,
  ) async {
    await openCatalog(tester);
    await tester.tap(find.text('Custom (${customCatalogItems.length})'));
    await settle(tester);
    await expectCards(tester, customCatalogItems);
    expect(find.text('AudioPlayer'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
