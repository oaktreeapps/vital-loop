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

// Tests for the expressions the server's screens are written with: the A2UI
// v1.0 basic functions as a2ui_core implements them, and the app's own
// `count`. They pin the exact forms the templates use, so a change in
// either shows up here and not as a wrong text on a screen.

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalloop/catalog/vitalloop_catalog.dart';

/// A surface with [data] as its data model and one Text whose text is
/// [value], checked against the strict catalog, and its processor.
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

void main() {
  test('count gives the length of text, lists and maps', () {
    expect(
      format(r'${count(value:${/notes})} / 280', {'notes': 'Hi'}),
      '2 / 280',
    );
    expect(
      format(r'${count(value:${/items})} selected', {
        'items': ['a', 'b', 'c'],
      }),
      '3 selected',
    );
    expect(
      format(r'${count(value:${/byName})}', {
        'byName': {'a': 1, 'b': 2},
      }),
      '2',
    );
    // Nothing there, or not something with a length: 0.
    expect(format(r'${count(value:${/missing})}|${/typed}'), '0|');
    expect(format(r'${count(value:${/n})}', {'n': 42}), '0');
  });

  test('a count picks the singular or the plural', () {
    const template =
        r'Continue · ${count(value:${/foods})} '
        r"${pluralize(value:${count(value:${/foods})}, one:'item', "
        r"other:'items')}";
    expect(
      format(template, {
        'foods': ['Rice'],
      }),
      'Continue · 1 item',
    );
    expect(format(template, {'foods': <String>[]}), 'Continue · 0 items');
  });

  test('a count of 0 picks the fallback text, else the value itself', () {
    const template =
        r'${pluralize(value:${count(value:${/typed})}, '
        r'zero:${/picked/0}, other:${/typed})}';
    expect(
      format(template, {
        'typed': '',
        'picked': ['Vitamin D'],
      }),
      'Vitamin D',
    );
    expect(
      format(template, {
        'typed': 'Omeprazole',
        'picked': ['Vitamin D'],
      }),
      'Omeprazole',
    );
  });

  test('a value under a name with a space is read with a binding', () {
    // A path in a ${...} expression can't hold a space; a binding can.
    final (_, NodeResolver<ComponentImplementation> resolver) = _surface(
      {
        '@call': 'pluralize',
        'args': {
          'value': {
            '@call': 'count',
            'args': {
              'value': {'@path': '/descriptions/Vitamin D'},
            },
          },
          'zero': 'No description yet.',
          'other': {'@path': '/descriptions/Vitamin D'},
        },
      },
      {
        'descriptions': {'Vitamin D': 'Supports bones.'},
      },
    );
    expect(_text(resolver), 'Supports bones.');
  });

  test('formatDate keeps the time as it was written', () {
    expect(
      format(
        r"${formatDate(value:'2026-11-09T14:05:00', "
        r"format:'d MMM, h:mm a')}",
      ),
      '9 Nov, 2:05 PM',
    );
  });

  test('a time from the data model is joined to a date, then formatted', () {
    // Quoted text in an expression is literal, so formatString builds the
    // date-time first.
    expect(
      format(
        r'${formatDate(value:${formatString('
        r"value:'2000-01-01T${/mealTime}')}, format:'h:mm a')}",
        {'mealTime': '13:00:00'},
      ),
      '1:00 PM',
    );
  });

  test('formatNumber shows a slider value without decimals', () {
    expect(
      format(r'${formatNumber(value:${/dosage}, decimals:0)}', {'dosage': 2}),
      '2',
    );
  });

  test('a text follows the data model', () {
    final (
      MessageProcessor<ComponentImplementation> processor,
      NodeResolver<ComponentImplementation> resolver,
    ) = _surface(
      {
        '@call': 'formatString',
        'args': {'value': r'${count(value:${/notes})} / 280'},
      },
      {'notes': ''},
    );
    expect(_text(resolver), '0 / 280');
    processor.model.getSurface('s')!.dataModel.set('/notes', 'Home cooked');
    expect(_text(resolver), '11 / 280');
  });

  test('the "picked or typed" check passes unless both are empty', () {
    Object? check(Map<String, Object?> data) {
      final (_, NodeResolver<ComponentImplementation> resolver) = _surface({
        '@call': 'regex',
        'args': {
          'value': {
            '@call': 'formatString',
            'args': {'value': r'${count(value:${/picked})}|${/typed}'},
          },
          'pattern': r'^(?!0\|\s*$)',
        },
      }, data);
      return ValidationResult.validityOf(_text(resolver));
    }

    expect(check({'picked': <String>[], 'typed': ''}), isFalse);
    expect(check({'picked': <String>[], 'typed': '  '}), isFalse);
    expect(
      check({
        'picked': ['Cough'],
        'typed': '',
      }),
      isTrue,
    );
    expect(check({'picked': <String>[], 'typed': 'Chills'}), isTrue);
  });
}
