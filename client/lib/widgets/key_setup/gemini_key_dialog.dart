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

import '../../core/theme/app_colors.dart';
import '../../services/gemini_key_setup.dart';
import '../common/app_dialog.dart';
import '../common/app_input_decoration.dart';
import '../common/primary_button.dart';
import 'copy_box.dart';
import 'setup_note.dart';
import 'step_label.dart';

/// The dialog that asks for a Gemini API key and sends it to the server.
///
/// It closes with `true` once the server has checked the key with Google and
/// saved it. Until then it can't be dismissed: the app needs the key.
class GeminiKeyDialog extends StatefulWidget {
  /// Creates a dialog that sends the key through [setup]; [status] says why
  /// the key is asked for.
  const GeminiKeyDialog({super.key, required this.setup, required this.status});

  /// Sends the key to the server.
  final GeminiKeySetup setup;

  /// Why the key is asked for: missing, or rejected (with Google's reason).
  final GeminiKeyStatus status;

  /// Creates the state that holds the typed key.
  @override
  State<GeminiKeyDialog> createState() => _GeminiKeyDialogState();
}

/// Holds the typed key, the error to show and the saving state.
class _GeminiKeyDialogState extends State<GeminiKeyDialog> {
  /// The key the user types or pastes.
  final TextEditingController _keyController = TextEditingController();

  /// Whether the key is hidden, like a password.
  bool _obscured = true;

  /// Whether the key is being checked and saved right now.
  bool _saving = false;

  /// Why the last key was refused; null when there is nothing to show.
  String? _error;

  /// Frees the text controller.
  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  /// Sends the key; closes the dialog when it's saved, or shows why not.
  Future<void> _save() async {
    final String key = _keyController.text.trim();
    if (key.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.setup.submit(key);
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error is GeminiKeySetupException
              ? error.message
              : "Couldn't save the key: $error";
        });
      }
    }
  }

  /// The title, why a key is needed, the two steps and Save.
  @override
  Widget build(BuildContext context) {
    final rejected = widget.status.state == GeminiKeyState.invalid;
    final reason = widget.status.message.isNotEmpty
        ? ': ${widget.status.message}'
        : '.';

    return AppDialog(
      icon: rejected ? Icons.key_off_rounded : Icons.key_rounded,
      warning: rejected,
      eyebrow: rejected ? 'Key not accepted' : 'One-time setup',
      title: rejected
          ? 'Gemini API key not accepted'
          : 'Add your Gemini API key',
      body: rejected
          ? 'Google rejected the key in server/.env$reason'
                ' Enter a working key to continue.'
          : 'This app uses Gemini to build its screens. Add your API key '
                'to start.',
      action: ValueListenableBuilder<TextEditingValue>(
        // Rebuilds only the button as the key is typed, to turn it on or off.
        valueListenable: _keyController,
        builder: (context, value, _) => PrimaryButton(
          label: 'Save and continue',
          busy: _saving,
          onPressed: value.text.trim().isEmpty || _saving ? null : _save,
        ),
      ),
      children: [
        const StepLabel(number: 1, text: 'Create a free key'),
        CopyBox(
          text: widget.status.keyUrl,
          copyTooltip: 'Copy link',
          link: true,
        ),
        const SizedBox(height: 18),
        const StepLabel(number: 2, text: 'Paste it here'),
        TextField(
          controller: _keyController,
          autofocus: true,
          obscureText: _obscured,
          autocorrect: false,
          enableSuggestions: false,
          enabled: !_saving,
          onSubmitted: (_) => _save(),
          style: appInputTextStyle(),
          cursorColor: AppColors.primary,
          decoration: appInputDecoration(
            hintText: 'Gemini API key',
            errorText: _error,
            suffixIcon: IconButton(
              tooltip: _obscured ? 'Show key' : 'Hide key',
              color: AppColors.textMuted,
              icon: Icon(
                _obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const SetupNote(
          icon: Icons.lock_outline_rounded,
          text: 'Saved on your server in server/.env, never in the app.',
        ),
      ],
    );
  }
}
