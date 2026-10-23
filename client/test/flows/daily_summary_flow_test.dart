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

// Tests for the health log and the daily summary: saving a flow adds a log
// entry, the dashboard shows badges and the "Generate summary" button, and
// the summary, care nearby and PDF report screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/care_map/widgets/care_map_view.dart';
import 'package:vitalloop/catalog/shared/widgets/care_place_card.dart';
import 'package:vitalloop/flows/vitals_flow.dart';
import 'package:vitalloop/models/care_place.dart';
import 'package:vitalloop/models/health_log.dart';
import 'package:vitalloop/screens/dashboard_screen.dart';
import 'package:vitalloop/screens/tracking_flow_screen.dart';

import '../support/fake_backend.dart';
import '../support/test_utils.dart';

/// A log entry for [flow], logged at a fixed time so the test does not
/// depend on the clock.
HealthLogEntry _entry(String flow, String category, String icon, String line) =>
    HealthLogEntry(
      flowName: flow,
      category: category,
      icon: icon,
      details: line,
      loggedAt: DateTime(2026, 9, 26, 9, 30),
    );

void main() {
  setUpTestEnvironment();

  testWidgets('saving a flow records one entry in the log', (tester) async {
    useLargeScreen(tester);
    await pumpFlow(tester, vitalsFlow, FakeBackend('vitals'));
    expect(healthLog.isEmpty, isTrue);

    await scrollAndTap(tester, button('Save readings'));
    await settle(tester);

    final HealthLogEntry entry = healthLog.entries.single;
    expect(entry.flowName, 'vitals');
    expect(entry.category, 'Vitals');
    expect(entry.details, startsWith('BP 118/76 mmHg · 72 bpm · 36.6 °C'));
    expect(entry.values['heartRate'], 72);
  });

  testWidgets('"Go to dashboard" leaves the summary for the dashboard', (
    tester,
  ) async {
    useLargeScreen(tester);
    final backends = <FakeBackend>[];
    await pumpDashboard(
      tester,
      transportFor: (flow) {
        backends.add(FakeBackend(flow.name));
        return backends.last;
      },
    );

    await scrollAndTap(tester, find.text('Vitals'));
    await settle(tester);
    await scrollAndTap(tester, button('Save readings'));
    await settle(tester);
    expect(find.text('Readings saved'), findsOneWidget);

    await scrollAndTap(tester, button('Go to dashboard'));
    await settle(tester);

    // Back on the dashboard, with the new entry's badge.
    expect(find.byType(TrackingFlowScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('1 logged'), findsOneWidget);
    // The app handled it; the backend never saw it.
    expect(backends.single.actions.map((a) => a['name']), ['vitalsEntered']);

    // Logging Vitals again starts a new flow and adds a second entry.
    await scrollAndTap(tester, find.text('Vitals'));
    await settle(tester);
    await scrollAndTap(tester, button('Save readings'));
    await settle(tester);
    expect(healthLog.entries, hasLength(2));
  });

  testWidgets('no entries: Generate summary is off', (tester) async {
    useLargeScreen(tester);
    await pumpDashboard(tester);

    expect(isEnabled(tester, 'Generate summary'), isFalse);
    expect(
      find.text("Log something to generate today's summary"),
      findsOneWidget,
    );
    expect(find.textContaining('logged'), findsNothing);
  });

  testWidgets('badges, summary, care nearby, then the PDF report', (
    tester,
  ) async {
    useLargeScreen(tester);
    healthLog
      ..add(_entry('pain', 'Pain', 'body', 'Lumbar Spine · pain 5/10'))
      ..add(_entry('vitals', 'Vitals', 'heartPulse', 'BP 115/75 mmHg · 72 bpm'))
      ..add(_entry('pain', 'Pain', 'body', 'Left Knee · pain 3/10'));

    final backends = <FakeBackend>[];
    await pumpDashboard(
      tester,
      transportFor: (flow) {
        backends.add(FakeBackend(flow.name));
        return backends.last;
      },
    );

    // Pain has two entries, Vitals one; the others none.
    expect(find.text('2 logged'), findsOneWidget);
    expect(find.text('1 logged'), findsOneWidget);
    expect(isEnabled(tester, 'Generate summary · 3 entries'), isTrue);

    await scrollAndTap(tester, button('Generate summary · 3 entries'));
    await settle(tester);

    // The summary screen, filled from the log.
    expect(find.byType(TrackingFlowScreen), findsOneWidget);
    expect(find.text('Your day at a glance'), findsOneWidget);
    expect(find.textContaining(' · 3 ENTRIES'), findsOneWidget);
    // The overview is written by the LLM; the fake backend uses its example.
    expect(
      find.textContaining('Here is everything you logged today'),
      findsOne,
    );
    expect(find.text('Lumbar Spine · pain 5/10'), findsOneWidget);
    expect(find.text('BP 115/75 mmHg · 72 bpm'), findsOneWidget);
    expect(find.text('Left Knee · pain 3/10'), findsOneWidget);

    // "Find care nearby" asks for a city, starting with California.
    expect(button('Generate PDF'), findsNothing);
    await scrollAndTap(tester, button('Find care nearby'));
    await tester.pumpAndSettle();
    expect(find.text('Where should we look?'), findsOneWidget);
    expect(find.widgetWithText(TextField, defaultCareCity), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Sacramento ');
    await tester.tap(button('Find care'));
    await settle(tester);

    // The city went to the backend, not the dialog's local action.
    final FakeBackend summary = backends.last;
    expect(summary.actions.last, {
      'name': 'findNearbyCare',
      'context': {'city': 'Sacramento'},
    });
    expect(
      summary.actions.map((a) => a['name']),
      isNot(contains('chooseCareCity')),
    );

    // The map and the list show the same places; Generate PDF is below.
    expect(find.text('Care near Sacramento'), findsOneWidget);
    expect(find.byType(CareMapView), findsOneWidget);
    expect(find.byType(CarePlaceCard), findsNWidgets(3));
    expect(find.text('Example General Hospital'), findsOneWidget);
    expect(find.text('Orthopedic care, for the pain you logged.'), findsOne);
    final Finder pdf = button('Generate PDF');
    expect(
      tester.getTopLeft(pdf).dy,
      greaterThan(tester.getTopLeft(find.byType(CarePlaceCard).last).dy),
    );

    // Tapping a card picks it, for the map too.
    await scrollAndTap(tester, find.text('Example Family Practice'));
    expect(
      tester.widget<CareMapView>(find.byType(CareMapView)).selectedId,
      'example-doctor',
    );

    // "Search another city" asks again, starting with the last city.
    await scrollAndTap(tester, button('Search another city'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Sacramento'), findsOneWidget);
    await tester.tapAt(const Offset(4, 4)); // Dismisses the dialog.
    await tester.pumpAndSettle();
    expect(find.text('Where should we look?'), findsNothing);

    await scrollAndTap(tester, pdf);
    await settle(tester);

    // The picked place went with Generate PDF, and shows under the report.
    expect(summary.actions.last['name'], 'generatePdf');
    expect(summary.actions.last['context'], {
      'selectedPlaceId': 'example-doctor',
    });
    expect(find.text('Your report is ready'), findsOneWidget);
    expect(find.text('Daily health report'), findsOneWidget);
    expect(find.text('3 entries · A4 PDF'), findsOneWidget);
    expect(button('Share PDF'), findsOneWidget);
    expect(button('Preview / print'), findsOneWidget);
    expect(find.text('CARE YOU CHOSE'), findsOneWidget);
    expect(find.byType(CarePlaceCard), findsOneWidget);
    expect(find.text('Example Family Practice'), findsOneWidget);

    // Finish clears the log and goes back to the dashboard, to start again;
    // the backend never sees it.
    expect(find.text('Back to summary'), findsNothing);
    await scrollAndTap(tester, button('Finish'));
    await settle(tester);
    expect(find.byType(TrackingFlowScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(healthLog.isEmpty, isTrue);
    expect(find.text('1 logged'), findsNothing);
    expect(summary.actions.map((a) => a['name']), isNot(contains('finish')));
  });

  testWidgets('no place picked: the report shows no place', (tester) async {
    useLargeScreen(tester);
    healthLog.add(_entry('pain', 'Pain', 'body', 'Left Knee · pain 3/10'));
    final backends = <FakeBackend>[];
    await pumpDashboard(
      tester,
      transportFor: (flow) {
        backends.add(FakeBackend(flow.name));
        return backends.last;
      },
    );

    await scrollAndTap(tester, button('Generate summary · 1 entry'));
    await settle(tester);
    await scrollAndTap(tester, button('Find care nearby'));
    await tester.pumpAndSettle();
    await tester.tap(button('Find care'));
    await settle(tester);
    await scrollAndTap(tester, button('Generate PDF'));
    await settle(tester);

    expect(backends.last.actions.last['name'], 'generatePdf');
    expect(backends.last.actions.last['context'], {'selectedPlaceId': ''});
    expect(find.text('Your report is ready'), findsOneWidget);
    expect(find.text('CARE YOU CHOSE'), findsNothing);
    expect(find.byType(CarePlaceCard), findsNothing);
  });
}
