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

// A fake backend for the widget tests: it serves the real screen templates
// from server/flows/ without the Python server or Gemini.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:genui/genui.dart';

import 'test_utils.dart';

/// Plays the Python backend's role in tests, without Gemini or a server.
///
/// Serves the screens in `server/flows/<flow>/` the way the backend's LLM
/// does: `flow.json` routes each request to a screen (`start` for the first
/// one, otherwise the UI action's name), shared screens get the flow's
/// `{{slots}}` and `{"$include": ...}` pulls in other files. Placeholders
/// such as `"{{mealType}}"` are filled with values from earlier actions;
/// `"{{a,b|rows}}"` builds `[{"item": ..., "amount": "1 serving"}]` rows,
/// `"{{a|text}}"` turns any value into readable text, `"{{a|lower}}"` and
/// `"{{a|upper}}"` the same in lower- and uppercase, and `"{{a,b|list}}"`
/// merges values into one list.
/// Filters chain left to right, e.g. `"{{a,b|list|text}}"`.
class FakeBackend implements Transport {
  /// A fake backend for [flow]; it starts with no values and no surfaces.
  FakeBackend(this.flow);

  /// The folder in `server/flows/`, e.g. "nutrition".
  final String flow;

  /// Every UI action received, e.g. `{"name": ..., "context": {...}}`.
  final List<Map<String, Object?>> actions = [];

  /// The A2UI messages sent to the app, one by one, like a streamed reply.
  final StreamController<core.A2uiMessage> _messages =
      StreamController.broadcast();

  /// Surface ids already created, with how often.
  final Map<String, int> _surfaceIds = {};

  /// Values from the user's actions so far, used to fill placeholders.
  final Map<String, Object?> _values = {};

  /// A placeholder that is a whole JSON value, quotes included:
  /// `"{{name}}"`, `"{{a,b}}"` or `"{{a,b|filter}}"`. Group 1 is the names,
  /// group 2 the filters (maybe empty).
  static final RegExp _wholeValue = RegExp(r'"\{\{([\w,]+)((?:\|\w+)*)\}\}"');

  /// A placeholder inside a longer string: `Step {{n}}`. Same groups as
  /// [_wholeValue].
  static final RegExp _inText = RegExp(r'\{\{([\w,]+)((?:\|\w+)*)\}\}');

  /// The A2UI messages of each screen, as the real backend would send them.
  @override
  Stream<core.A2uiMessage> get incomingMessages => _messages.stream;

  /// The real backend sends no plain text, so neither does this one.
  @override
  Stream<String> get incomingText => const Stream.empty();

  /// Answers [message] with the next screen.
  ///
  /// A UI action picks the route by its name and saves its context values
  /// for the placeholders; plain text (the start of a flow) uses the
  /// "start" route and clears the saved values. An `{"error": ...}` report
  /// from the app gets no answer, like on the real backend. Every action is
  /// also kept in [actions], so tests can check what the app sent.
  @override
  Future<void> sendRequest(ChatMessage message) async {
    final String request = message.parts
        .map(
          (part) => part.isUiInteractionPart
              ? part.asUiInteractionPart!.interaction
              : part is TextPart
              ? part.text
              : '',
        )
        .join();

    Object? json;
    try {
      json = jsonDecode(request);
    } on FormatException {
      // Plain text, e.g. the message that starts the flow.
    }
    if (json case {'error': _}) return;

    var route = 'start';
    if (json case {'action': final Map<String, Object?> action}) {
      actions.add(action);
      route = action['name']! as String;
      if (action['context'] case final Map<Object?, Object?> context) {
        _values.addAll(context.cast<String, Object?>());
      }
    } else {
      _values.clear();
    }

    final String? screen = _loadScreens()[route];
    if (screen == null) throw StateError('No screen for "$route" in $flow');
    final List<Object?> messages = _uniqueSurfaceIds(
      _resolvePlaces(jsonDecode(_fill(screen))) as List<Object?>,
    );
    for (final message in messages) {
      _messages.add(
        core.A2uiMessage.fromJson(message! as Map<String, Object?>),
      );
    }
  }

  /// Closes the message stream.
  @override
  void dispose() => _messages.close();

  // ---- Loading, like server/screens.py ----

  /// Reads the flow's flow.json and returns {route: screen JSON text}, like
  /// `load_screens` in server/screens.py. Keys that start with "_" are
  /// comments and are skipped.
  ///
  /// The flows are read from [serverFlowsDir].
  Map<String, String> _loadScreens() {
    final folder = Directory('$serverFlowsDir/$flow');
    final routes =
        jsonDecode(File('${folder.path}/flow.json').readAsStringSync())
            as Map<String, Object?>;
    return {
      for (final MapEntry<String, Object?> route in routes.entries)
        if (!route.key.startsWith('_'))
          route.key: switch (route.value) {
            final String file => _loadScreen('${folder.path}/$file', const {}),
            {
              'screen': final String file,
              'with': final Map<String, Object?> w,
            } =>
              _loadScreen('${folder.path}/$file', w),
            {'screen': final String file} => _loadScreen(
              '${folder.path}/$file',
              const {},
            ),
            _ => throw FormatException('Bad route ${route.key} in $flow'),
          },
    };
  }

  /// Reads one screen file, expands its includes and fills its [slots] (the
  /// "with" values of a shared screen). A slot that is a whole JSON value
  /// becomes that value; a text slot inside a longer string becomes text.
  String _loadScreen(String path, Map<String, Object?> slots) {
    final file = File(path);
    final Object? screen = _expandIncludes(
      jsonDecode(file.readAsStringSync()),
      file.parent,
    );
    String filled = jsonEncode(screen);
    for (final MapEntry<String, Object?> slot in slots.entries) {
      filled = filled.replaceAll('"{{${slot.key}}}"', jsonEncode(slot.value));
      if (slot.value case final String text) {
        final String escaped = jsonEncode(text);
        filled = filled.replaceAll(
          '{{${slot.key}}}',
          escaped.substring(1, escaped.length - 1),
        );
      }
    }
    return filled;
  }

  /// Replaces every `{"$include": "path"}` in [node] with that file's JSON;
  /// a path is relative to the folder [base] of the file that includes it.
  /// Keys next to `$include` are merged into the included JSON.
  ///
  /// Also stands in for the LLM-generated parts: `{"$ai": ..., "example":
  /// ...}` becomes its example. A `{"$places": ...}` list lists only each
  /// place's id and reason; like the real server, the facts are added from
  /// the search's results, here [_examplePlaces] (see [_withFacts]).
  Object? _expandIncludes(Object? node, Directory base) {
    if (node is Map) {
      if (node.containsKey(r'$ai')) return node['example'];
      if (node.length == 1 && node.containsKey(r'$places')) {
        return _withFacts(_expandIncludes(node[r'$places'], base));
      }
      if (node[r'$include'] case final String path) {
        final file = File('${base.path}/$path');
        return _merge(
          _expandIncludes(jsonDecode(file.readAsStringSync()), file.parent),
          _expandIncludes({...node}..remove(r'$include'), base),
        );
      }
      return {
        for (final MapEntry<Object?, Object?> e in node.entries)
          e.key: _expandIncludes(e.value, base),
      };
    }
    if (node is List) return [for (final i in node) _expandIncludes(i, base)];
    return node;
  }

  /// [base] with [overrides] on top: maps merge key by key, recursively;
  /// any other value in [overrides] replaces the one in [base].
  static Object? _merge(Object? base, Object? overrides) {
    if (base is! Map || overrides is! Map) return overrides;
    return {
      ...base,
      for (final MapEntry<Object?, Object?> e in overrides.entries)
        e.key: base.containsKey(e.key) ? _merge(base[e.key], e.value) : e.value,
    };
  }

  // ---- What the server does: places' facts, the picked place ----

  /// What the server's nearby search returns for the template's example
  /// places, by id, from test/fixtures/example_places.json.
  static final Map<String, Map<String, Object?>> _examplePlaces = {
    for (final Object? place
        in jsonDecode(
              File('test/fixtures/example_places.json').readAsStringSync(),
            )
            as List<Object?>)
      if (place case {'id': final String id})
        id: (place as Map).cast<String, Object?>(),
  };

  /// The places in [listed] (`{"id", "reason"}` each) with their facts, like
  /// `places.resolve_places` on the server. Unknown ids are dropped.
  List<Object?> _withFacts(Object? listed) => [
    if (listed is List)
      for (final Object? item in listed)
        if (item case {'id': final String id})
          if (_examplePlaces[id] case final Map<String, Object?> facts)
            {...facts, if (item['reason'] case final String r) 'reason': r},
  ];

  /// Every place a screen listed so far, by id, without its empty facts:
  /// what a `{"$place": id}` becomes, like the server's search results.
  final Map<String, Map<String, Object?>> _places = {};

  /// Records the places in [node]'s "places" lists, and replaces each
  /// `{"$place": id}` value with the recorded place. Without a known id
  /// (e.g. nothing was picked) the key is dropped, like
  /// `places.resolve_places` on the server.
  Object? _resolvePlaces(Object? node) {
    if (node is List) return [for (final i in node) _resolvePlaces(i)];
    if (node is! Map) return node;
    if (node['places'] case final List<Object?> places) {
      for (final place in places) {
        if (place case {'id': final String id}) {
          _places[id] = {
            for (final MapEntry<Object?, Object?> e in place.entries)
              if (e.value != null) e.key! as String: e.value,
          };
        }
      }
    }
    final resolved = <String, Object?>{};
    for (final MapEntry<Object?, Object?> e in node.entries) {
      final key = e.key! as String;
      if (e.value case {r'$place': final Object? id}) {
        if (_places[id] case final Map<String, Object?> place) {
          resolved[key] = place;
        }
      } else {
        resolved[key] = _resolvePlaces(e.value);
      }
    }
    return resolved;
  }

  // ---- What the LLM does: unique surfaces, filled placeholders ----

  /// Gives a surface created again (e.g. step 1 when the flow starts over) a
  /// new id, like server/agent.py: the app can't create a surface twice.
  /// A deleteSurface keeps the old id, so it removes the old surface.
  List<Object?> _uniqueSurfaceIds(List<Object?> messages) {
    final renamed = <String, String>{};
    for (final message in messages) {
      if (message case {'createSurface': {'surfaceId': final String id}}) {
        final int seen = _surfaceIds[id] = (_surfaceIds[id] ?? 0) + 1;
        if (seen > 1) renamed[id] = '${id}_$seen';
      }
    }
    for (final message in messages) {
      for (final MapEntry<Object?, Object?> e in (message! as Map).entries) {
        if (e.key == 'deleteSurface') continue;
        if (e.value case {
          'surfaceId': final String id,
        } when renamed.containsKey(id)) {
          (e.value! as Map)['surfaceId'] = renamed[id];
        }
      }
    }
    return messages;
  }

  /// Replaces `"{{key}}"` with the JSON value of `key`, and `{{key}}` inside
  /// a longer string with readable text (lists joined with ", ").
  String _fill(String screen) => screen
      .replaceAllMapped(_wholeValue, (m) => jsonEncode(_lookup(m[1]!, m[2])))
      .replaceAllMapped(_inText, (m) {
        final String escaped = jsonEncode(_asText(_lookup(m[1]!, m[2])));
        return escaped.substring(1, escaped.length - 1);
      });

  /// The value for [names] (`a` or `a,b`) after applying [filters], a chain
  /// such as `|list|text`, left to right.
  Object? _lookup(String names, String? filters) {
    final List<String> keys = names.split(',');
    // {{now}}: the current local date and time.
    Object? value = keys.first == 'now' ? _now() : _values[keys.first];
    for (final String filter in (filters ?? '').split('|')) {
      value = switch (filter) {
        '' => value,
        'list' => _flatList(keys),
        'rows' => [
          for (final item in _flatList(keys))
            {'item': item, 'amount': '1 serving'},
        ],
        'text' => _asText(value),
        'lower' => _asText(value).toLowerCase(),
        'upper' => _asText(value).toUpperCase(),
        _ => throw FormatException('Unknown placeholder filter "$filter"'),
      };
    }
    return value;
  }

  /// The values of [keys] as one list of strings: lists are merged and text
  /// is split at commas; blanks are dropped.
  List<String> _flatList(List<String> keys) => [
    for (final key in keys)
      ...switch (_values[key]) {
        final List<Object?> list => list.whereType<String>(),
        final String text => text.split(','),
        _ => const <String>[],
      }.map((item) => item.trim()).where((item) => item.isNotEmpty),
  ];

  /// [value] as text a person can read: whole numbers without ".0", lists
  /// joined with ", ", and a map's values joined with " – ".
  String _asText(Object? value) => switch (value) {
    null => '',
    final String text => text,
    final num n when n == n.roundToDouble() => '${n.round()}',
    final List<Object?> list =>
      list.map(_asText).where((t) => t.isNotEmpty).join(', '),
    final Map<Object?, Object?> map =>
      map.values.map(_asText).where((t) => t.isNotEmpty).join(' – '),
    _ => '$value',
  };

  /// `yyyy-MM-ddTHH:mm:00`, the format genui's DateTimeInput reads.
  static String _now() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}'
        'T${two(now.hour)}:${two(now.minute)}:00';
  }
}
