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

/// The app's screens and their paths, e.g. `/flow/pain`.
///
/// Every screen sits under the dashboard, so going back always ends there,
/// even after opening a path directly (e.g. a link on the web).
abstract final class AppRoutes {
  /// The dashboard: the list of flows.
  static const String dashboard = '/';

  /// The daily summary of today's entries.
  static const String summary = '/summary';

  /// The component catalog preview.
  static const String catalog = '/catalog';

  /// The path of the tracking flow named [flowName], e.g. `/flow/pain`.
  static String flow(String flowName) => '/flow/$flowName';
}
