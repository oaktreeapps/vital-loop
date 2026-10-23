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

// Tests for reading the custom components' optional JSON properties.

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/shared/data_binding.dart';

void main() {
  test('numberOrNull keeps numbers only', () {
    expect(numberOrNull(5), 5);
    expect(numberOrNull(2.5), 2.5);
    expect(numberOrNull('5'), isNull);
    expect(numberOrNull(null), isNull);
  });

  test('stringOrNull keeps strings only', () {
    expect(stringOrNull('Pain'), 'Pain');
    expect(stringOrNull(''), '');
    expect(stringOrNull(5), isNull);
    expect(stringOrNull({'path': '/x'}), isNull);
  });
}
