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

import '../catalog/care_list/care_list.dart';
import '../catalog/care_map/care_map.dart';
import '../catalog/icon_badge/icon_badge.dart';
import '../catalog/pdf_report/pdf_report.dart';
import '../core/utils/text_format.dart';
import '../models/health_log.dart';
import '../models/tracking_flow.dart';
import '../services/genui_session.dart';

/// The daily summary of [entries]: an overview of the day, then care nearby
/// (a map and a list of places in a city the user picks), then a PDF report.
///
/// The first request is a "generateSummary" action carrying the entries, so
/// the backend's LLM fills them into its screens and writes about them.
/// [day] is the date shown on the summary; it defaults to today.
///
/// Unlike the other flows, this one saves nothing to the [HealthLog]: it has
/// no `saveAction`. Its screens may use [iconBadge], [pdfReport], [careMap]
/// and [careList].
TrackingFlow dailySummaryFlow(List<HealthLogEntry> entries, {DateTime? day}) {
  // Each category once, in the order it was first logged.
  final List<String> categories = {
    for (final HealthLogEntry e in entries) e.category,
  }.toList();
  final int count = entries.length;
  return TrackingFlow(
    name: 'daily_summary',
    // An A2UI client message, so the backend treats it as a button press
    // and not as text typed by the user.
    startMessage: actionMessage('generateSummary', {
      'date': formatDay(day ?? DateTime.now()),
      'entryCount': count,
      'entryCountLabel': '$count ${count == 1 ? 'entry' : 'entries'}',
      'categories': categories,
      'entries': [for (final HealthLogEntry e in entries) e.toJson()],
    }),
    loadingLabel: 'Writing your summary…',
    customItems: [iconBadge, pdfReport, careMap, careList],
  );
}
