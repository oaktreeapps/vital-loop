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
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

/// Logger for links that can't be opened.
final Logger _log = Logger('openLink');

/// Opens [uri] outside the app: a web page or Google Maps in its app or the
/// browser, or a `tel:` link in the phone app.
///
/// When nothing can open it (e.g. no phone app on a tablet), a snack bar
/// says that [what] couldn't be opened, e.g. "directions".
Future<void> openLink(BuildContext context, Uri uri, String what) async {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException catch (error) {
    _log.warning('Could not open ${uri.scheme} link: $error');
  }
  if (!opened) {
    messenger?.showSnackBar(
      SnackBar(content: Text("Couldn't open $what on this device.")),
    );
  }
}
