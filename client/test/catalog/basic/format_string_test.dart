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

// Tests for the app's formatString and the functions it calls: the screens
// are written for exactly this behaviour (kept from genui when the app moved
// to A2UI v1.0).

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/vitalloop_catalog.dart';

/// A surface with [data] as its data model and one Text whose text is
/// [value], and the processor that owns it.
(
  MessageProcessor<ComponentImplementation>,
  NodeResolver<ComponentImplementation>,
)
_surface(Object? value, Map<String, Object?> data) {
  final processor = MessageProcessor<ComponentImplementation>(
    catalogs: [vitalLoopCatalog(strict: true)],
    validationConfig: ValidationConfig.strict,
  );
  processor.processMessages([
    {
      'version': '1.0',
      'createSurface': {'surfaceId': 's', 'catalogId': vitalLoopCatalogId},
    },
    {
      'version': '1.0',
      'updateDataModel': {'surfaceId': 's', 'path': '/', 'value': data},
    },
    {
      'version': '1.0',
      'updateComponents': {
        'surfaceId': 's',
        'components': [
          {'id': 'root', 'component': 'Text', 'text': value},
        ],
      },
    },
  ]);
  final resolver = NodeResolver<ComponentImplementation>(
    processor.model.getSurface('s')!,
  );
  addTearDown(() {
    resolver.dispose();
    processor.dispose();
  });
  return (processor, resolver);
}

/// What the Text of [resolver]'s surface shows right now.
Object? _text(NodeResolver<ComponentImplementation> resolver) =>
    ComponentProps(resolver.rootNode.value!.props.value).value('text');

/// The result of `formatString` for [template] with [data] as data model.
Object? format(String template, [Map<String, Object?> data = const {}]) {
  final (_, NodeResolver<ComponentImplementation> resolver) = _surface({
    '@call': 'formatString',
    'args': {'value': template},
  }, data);
  return _text(resolver);
}

/// The result of calling the catalog function [name] with [args].
Object? call(String name, Map<String, Object?> args) {
  final (_, NodeResolver<ComponentImplementation> resolver) = _surface({
    '@call': name,
    'args': args,
  }, const {});
  return _text(resolver);
}

void main() {
  group('formatString', () {
    test('text without expressions stays as it is', () {
      expect(format('Step 1 of 5'), 'Step 1 of 5');
      expect(format(''), '');
    });

    test('paths are filled from the data model', () {
      expect(format(r'Hello ${/name}!', {'name': 'Asha'}), 'Hello Asha!');
      expect(
        format(r'${/mealDay/0}', {
          'mealDay': ['Today'],
        }),
        'Today',
      );
      // A missing value is empty text, not "null".
      expect(format(r'[${/missing}]'), '[]');
    });

    test(r'\${ is a literal ${', () {
      expect(format(r'Use \${name}'), r'Use ${name}');
    });

    test('length counts text and lists, as the screens rely on', () {
      expect(
        format(r'${length(value:${/notes})} / 280', {'notes': 'Hi'}),
        '2 / 280',
      );
      expect(
        format(r'${length(value:${/items})} selected', {
          'items': ['a', 'b', 'c'],
        }),
        '3 selected',
      );
      expect(format(r'${length(value:${/missing})}|${/typed}'), '0|');
    });

    test('pluralize picks by count, with expressions in its texts', () {
      const template =
          r'Continue · ${length(value:${/foods})} '
          r"${pluralize(value:${length(value:${/foods})}, one:'item', other:'items')}";
      expect(
        format(template, {
          'foods': ['Rice'],
        }),
        'Continue · 1 item',
      );
      expect(format(template, {'foods': <String>[]}), 'Continue · 0 items');

      // Quoted text is filled too: the typed name wins over the picked one.
      const name =
          r'${pluralize(value:${length(value:${/typed})}, '
          r"zero:'${/picked/0}', other:'${/typed}')}";
      expect(
        format(name, {
          'typed': '',
          'picked': ['Vitamin D'],
        }),
        'Vitamin D',
      );
      expect(
        format(name, {
          'typed': 'Omeprazole',
          'picked': ['Vitamin D'],
        }),
        'Omeprazole',
      );
    });

    test('formatDate takes a pattern, and a time glued onto a date', () {
      expect(
        format(
          r"${formatDate(value:'2026-11-09T14:05:00', "
          r"pattern:'d MMM, h:mm a')}",
        ),
        '9 Nov, 2:05 PM',
      );
      expect(
        format(
          r"${formatDate(value:'2000-01-01T${/mealTime}', pattern:'h:mm a')}",
          {'mealTime': '13:00:00'},
        ),
        '1:00 PM',
      );
    });

    test('formatNumber rounds a slider value for display', () {
      expect(
        format(r'${formatNumber(value:${/dosage}, decimalPlaces:0)}', {
          'dosage': 2.0,
        }),
        '2',
      );
    });

    test('an unknown function gives nothing instead of failing', () {
      expect(format(r'[${nope(value:1)}]'), '[]');
    });

    test('the text follows the data model', () {
      final (
        MessageProcessor<ComponentImplementation> processor,
        NodeResolver<ComponentImplementation> resolver,
      ) = _surface(
        {
          '@call': 'formatString',
          'args': {'value': r'${length(value:${/notes})} / 280'},
        },
        {'notes': ''},
      );
      expect(_text(resolver), '0 / 280');
      processor.model.getSurface('s')!.dataModel.set('/notes', 'Home cooked');
      expect(_text(resolver), '11 / 280');
    });
  });

  group('check functions', () {
    test('required is false for nothing, empty text and empty lists', () {
      expect(call('required', {'value': 'x'}), true);
      expect(call('required', {'value': ''}), false);
      expect(call('required', {'value': <Object?>[]}), false);
      expect(call('required', {'value': 0}), true);
    });

    test('regex searches the text for the pattern', () {
      expect(call('regex', {'value': 'abc', 'pattern': 'b'}), true);
      expect(call('regex', {'value': 'abc', 'pattern': '^b'}), false);
      // The notes check: at most 280 characters, line breaks included.
      const pattern = r'^[\s\S]{0,280}$';
      expect(call('regex', {'value': 'x' * 280, 'pattern': pattern}), true);
      expect(call('regex', {'value': 'x' * 281, 'pattern': pattern}), false);
    });

    test('length with min or max checks instead of counting', () {
      expect(call('length', {'value': 'abc'}), 3);
      expect(call('length', {'value': 'abc', 'min': 4}), false);
      expect(call('length', {'value': 'abc', 'max': 3}), true);
    });

    test('formatDate also takes the v1.0 name of the pattern, format', () {
      expect(
        call('formatDate', {'value': '2026-11-09T14:05:00', 'format': 'yyyy'}),
        '2026',
      );
    });
  });
}
