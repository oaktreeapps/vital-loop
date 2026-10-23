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

// Tests for the app's paths.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/core/router/app_routes.dart';

void main() {
  test('each screen has its own path', () {
    expect(AppRoutes.dashboard, '/');
    expect(AppRoutes.summary, '/summary');
    expect(AppRoutes.catalog, '/catalog');
  });

  test("a flow's path is /flow/ and its name", () {
    expect(AppRoutes.flow('pain'), '/flow/pain');
    expect(AppRoutes.flow('daily_summary'), '/flow/daily_summary');
  });
}
