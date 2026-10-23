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
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

import '../core/router/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/health_log.dart';
import '../models/health_option.dart';
import '../widgets/dashboard/circle_icon_button.dart';
import '../widgets/dashboard/option_card.dart';
import '../widgets/dashboard/start_over_dialog.dart';
import '../widgets/dashboard/summary_bar.dart';
import 'catalog_screen.dart';
import 'tracking_flow_screen.dart';

/// Logger for this screen's messages.
final Logger _log = Logger('DashboardScreen');

/// "Good morning" / "Good afternoon" / "Good evening" for [time].
String greetingFor(DateTime time) => switch (time.hour) {
  >= 5 && < 12 => 'Good morning',
  >= 12 && < 17 => 'Good afternoon',
  _ => 'Good evening',
};

/// The app's home screen: lists the health tracking options, with the
/// start over and component catalog buttons in the top row.
class DashboardScreen extends StatefulWidget {
  /// Creates the dashboard.
  const DashboardScreen({super.key});

  /// Creates the state that opens flows from the dashboard.
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// State of [DashboardScreen]: opens a flow, the daily summary or the
/// catalog when the user taps them.
class _DashboardScreenState extends State<DashboardScreen> {
  /// Opens the [TrackingFlowScreen] for [option].
  void _open(HealthTrackingOption option) {
    _log.info('DashboardScreen → ${AppRoutes.flow(option.flow.name)}');
    context.push(AppRoutes.flow(option.flow.name));
  }

  /// Opens the daily summary of today's [healthLog] entries, so the backend
  /// can write a summary of them.
  void _openSummary() {
    _log.info(
      'DashboardScreen → ${AppRoutes.summary} '
      '(${healthLog.entries.length} entries)',
    );
    context.push(AppRoutes.summary);
  }

  /// Asks in a [StartOverDialog], then clears today's [healthLog] so the
  /// user can start again.
  Future<void> _startOver() async {
    final int count = healthLog.entries.length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      // Over this screen's navigator, so it stays inside the app when the
      // app is embedded in a page (the showcase website's phone).
      useRootNavigator: false,
      builder: (_) => StartOverDialog(entryCount: count),
    );
    if (confirmed != true) return;
    _log.info('Start over → healthLog.clear ($count entries)');
    healthLog.clear();
  }

  /// Opens the [CatalogScreen] that previews the default and custom
  /// components.
  void _openCatalog() {
    _log.info('DashboardScreen → ${AppRoutes.catalog}');
    context.push(AppRoutes.catalog);
  }

  /// Builds the greeting, the title, one card per tracking option and the
  /// summary bar at the bottom.
  @override
  Widget build(BuildContext context) {
    _log.fine('build');
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: ListenableBuilder(
        // Badges and the summary button follow today's log.
        listenable: healthLog,
        builder: (context, _) => Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: SummaryBar(
            entryCount: healthLog.entries.length,
            onPressed: _openSummary,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        greetingFor(DateTime.now()).toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: AppColors.eyebrow,
                        ),
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.restart_alt_rounded,
                      tooltip: 'Start over',
                      // Nothing to clear before anything is logged.
                      onTap: healthLog.isEmpty ? null : _startOver,
                    ),
                    const SizedBox(width: 8),
                    CircleIconButton(
                      icon: Icons.widgets_outlined,
                      tooltip: 'Component catalog',
                      onTap: _openCatalog,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Semantics(
                  header: true,
                  child: Text(
                    'What would you like to log today?',
                    style: GoogleFonts.fraunces(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                      letterSpacing: -0.4,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                for (final option in HealthTrackingOption.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: OptionCard(
                      option: option,
                      logged: healthLog.countFor(option.flow.name),
                      onTap: () => _open(option),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
