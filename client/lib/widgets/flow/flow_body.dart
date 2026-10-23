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

import '../../core/theme/surface_theme.dart';
import '../../services/backend_transport.dart';
import '../../services/genui_session.dart';
import 'flow_error_view.dart';
import 'flow_loading_view.dart';

/// What the flow shows for its session's state: an error with a retry
/// button, a loading spinner before the first surface, or the latest surface
/// (with a progress bar while the next step is on its way).
class FlowBody extends StatelessWidget {
  /// Creates the body for [session].
  const FlowBody({
    super.key,
    required this.session,
    required this.loadingLabel,
    required this.onRetry,
  });

  /// The flow's running session.
  final GenUiSession session;

  /// The text under the spinner before the first surface.
  final String loadingLabel;

  /// Starts the flow over, from the error view.
  final VoidCallback onRetry;

  /// Builds the error view, the spinner or the latest surface.
  @override
  Widget build(BuildContext context) {
    final String? surfaceId = session.currentSurfaceId;
    final Object? error = session.error;

    if (error != null && !session.isProcessing) {
      return FlowErrorView(
        message: error is BackendException
            ? error.message
            : 'Please try again.',
        onRetry: onRetry,
      );
    }

    if (surfaceId == null) {
      return FlowLoadingView(label: loadingLabel);
    }

    final SurfaceContext surface = session.surfaceHost.contextFor(surfaceId);
    return Column(
      children: [
        if (session.isProcessing) const LinearProgressIndicator(),
        Expanded(
          child: AbsorbPointer(
            // Block taps while the next step is being generated.
            absorbing: session.isProcessing,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              // A new key per surface makes the switcher fade between steps.
              child: SurfaceTheme(
                key: ValueKey(surfaceId),
                surfaceContext: surface,
                child: SizedBox.expand(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Surface(surfaceContext: surface),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
