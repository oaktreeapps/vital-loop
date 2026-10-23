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
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// A beige box with selectable [text] (a link or a command) and a copy
/// button.
class CopyBox extends StatefulWidget {
  /// Creates the box for [text].
  const CopyBox({
    super.key,
    required this.text,
    required this.copyTooltip,
    this.link = false,
  });

  /// The text to show and copy.
  final String text;

  /// The copy button's tooltip, e.g. "Copy link".
  final String copyTooltip;

  /// Whether [text] is a link (shown in green) rather than a command (shown
  /// in a monospace font).
  final bool link;

  @override
  State<CopyBox> createState() => _CopyBoxState();
}

/// Remembers whether the text was just copied, to show a check mark.
class _CopyBoxState extends State<CopyBox> {
  /// Whether the text was copied.
  bool _copied = false;

  /// Copies the text; the app can't open a browser or a terminal itself.
  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
      decoration: BoxDecoration(
        color: AppColors.chevronFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SelectableText(
                widget.text,
                style: widget.link
                    ? GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.logged,
                      )
                    : GoogleFonts.robotoMono(
                        fontSize: 13,
                        color: AppColors.text,
                      ),
              ),
            ),
          ),
          IconButton(
            tooltip: _copied ? 'Copied' : widget.copyTooltip,
            color: _copied ? AppColors.logged : AppColors.textMuted,
            icon: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 20,
            ),
            onPressed: _copy,
          ),
        ],
      ),
    );
  }
}
