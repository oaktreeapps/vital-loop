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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../core/theme/app_colors.dart';
import '../services/gemini_key_setup.dart';
import '../widgets/key_setup/gemini_key_dialog.dart';
import '../widgets/key_setup/server_unreachable_dialog.dart';

/// Logs the key check and what the user is asked.
final Logger _logger = Logger('GeminiKeyGate');

/// Shows [child] (the dashboard) once the server has a working Gemini API key.
///
/// On start it asks the server about its key. Until the key is confirmed,
/// [child] is visible but can't be tapped. If the key is missing or rejected,
/// a [GeminiKeyDialog] in the middle of the screen asks for one; if the server
/// can't be reached, a dialog says how to start it, with a Retry button.
class GeminiKeyGate extends StatefulWidget {
  /// Creates a gate that guards [child] with the key check, done through
  /// [setup].
  const GeminiKeyGate({
    super.key,
    required this.child,
    this.setup,
    this.navigatorKey,
  });

  /// The app, shown and usable once the key works.
  final Widget child;

  /// How to check and send the key; [HttpGeminiKeySetup] by default. Tests
  /// pass their own.
  final GeminiKeySetup? setup;

  /// The navigator to show the dialogs in, when the gate sits above it (as
  /// around the app's router). Without it, the nearest one is used.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Creates the state that runs the check.
  @override
  State<GeminiKeyGate> createState() => _GeminiKeyGateState();
}

/// Runs the key check and shows the dialogs until the key works.
class _GeminiKeyGateState extends State<GeminiKeyGate> {
  /// The setup in use: [GeminiKeyGate.setup], or the HTTP one.
  late final GeminiKeySetup _setup = widget.setup ?? HttpGeminiKeySetup();

  /// Whether [_setup] was created here, so [dispose] should close it.
  late final bool _ownsSetup = widget.setup == null;

  /// Whether the key works, so the app can be used.
  bool _ready = false;

  /// Whether the app is asking the server right now (shows a progress bar).
  bool _checking = true;

  /// Starts the check once the first frame is up, so dialogs can open.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_check()));
  }

  /// Closes the HTTP setup if this gate created it.
  @override
  void dispose() {
    if (_ownsSetup) _setup.close();
    super.dispose();
  }

  /// Asks the server about its key, and asks the user until it works.
  Future<void> _check() async {
    while (mounted) {
      GeminiKeyStatus? status;
      String? unreachable;
      setState(() => _checking = true);
      try {
        status = await _setup.status();
      } on GeminiKeySetupException catch (error) {
        unreachable = error.message;
      } on Exception catch (error, stackTrace) {
        // Anything unexpected: still let the user retry instead of hanging.
        _logger.severe('Key check failed', error, stackTrace);
        unreachable = "Couldn't check the Gemini API key: $error";
      }
      if (!mounted) return;
      setState(() => _checking = false);
      if (status?.state == GeminiKeyState.ok) {
        _logger.info('The server has a working Gemini API key → app ready');
        setState(() => _ready = true);
        return;
      }

      _logger.info(
        unreachable != null
            ? 'Server unreachable → asking to start it'
            : 'Gemini API key ${status!.state.name} → asking for one',
      );
      // true: a key was saved; false: try again (after "Retry").
      final bool saved =
          await showDialog<bool>(
            context: widget.navigatorKey?.currentContext ?? context,
            barrierDismissible: false,
            builder: (_) => unreachable != null
                ? ServerUnreachableDialog(message: unreachable)
                : GeminiKeyDialog(setup: _setup, status: status!),
          ) ??
          false;
      if (saved && mounted) {
        _logger.info('Gemini API key saved → app ready');
        setState(() => _ready = true);
        return;
      }
    }
  }

  /// The app, blocked until the key works, with a thin progress bar while
  /// the server is being asked.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blocks taps and keyboard focus until the key works.
        ExcludeFocus(
          excluding: !_ready,
          child: AbsorbPointer(absorbing: !_ready, child: widget.child),
        ),
        if (!_ready && _checking)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.border,
              ),
            ),
          ),
      ],
    );
  }
}
