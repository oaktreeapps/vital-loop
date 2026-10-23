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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/app_dialog.dart';
import '../common/primary_button.dart';
import 'copy_box.dart';
import 'step_label.dart';

/// The dialog shown when the server can't be reached: how to start it, and
/// Retry.
class ServerUnreachableDialog extends StatelessWidget {
  /// Creates the dialog with [message], which says where the app looked.
  const ServerUnreachableDialog({super.key, required this.message});

  /// Where the app looked for the server.
  final String message;

  /// The command that starts the server, from the repository root.
  static const String _startCommand = 'cd server && .venv/bin/python main.py';

  /// The command that lets a phone on USB reach the computer's `localhost`.
  static const String _adbCommand = 'adb reverse tcp:10002 tcp:10002';

  /// The steps to start the server and a Retry button, which closes the
  /// dialog with `false` so the gate checks again.
  @override
  Widget build(BuildContext context) {
    final bool android =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return AppDialog(
      icon: Icons.cloud_off_rounded,
      warning: true,
      eyebrow: 'Connection',
      title: "Can't reach the server",
      body: message,
      action: PrimaryButton(
        label: 'Retry',
        icon: Icons.refresh_rounded,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      children: [
        const StepLabel(number: 1, text: 'Start the server on your computer'),
        const CopyBox(text: _startCommand, copyTooltip: 'Copy command'),
        if (android) ...[
          const SizedBox(height: 18),
          const StepLabel(number: 2, text: 'On a phone over USB, also run'),
          const CopyBox(text: _adbCommand, copyTooltip: 'Copy command'),
        ],
      ],
    );
  }
}
