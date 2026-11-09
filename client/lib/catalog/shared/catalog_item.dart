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

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../services/transport.dart' show JsonMap;

export '../../services/transport.dart' show JsonMap;

/// What a [CatalogItem]'s builder gets to build one component of a surface.
class CatalogItemContext {
  /// Wraps what a2ui_flutter passes to a component builder.
  CatalogItemContext({
    required this.buildContext,
    required this.node,
    required this.props,
    required this.buildChild,
  });

  /// The Flutter context the component is built in.
  final BuildContext buildContext;

  /// The component's node in the surface's resolved tree.
  final ComponentNode<ComponentImplementation> node;

  /// The component's properties with bindings and child references resolved.
  final ComponentProps props;

  /// Builds the widget of a child node from [props].
  final ChildWidgetBuilder buildChild;

  /// The component's id in the screen's JSON, e.g. "save".
  String get id => node.componentId;

  /// The component's type, e.g. "Button".
  String get type => node.type;

  /// The component's properties as the JSON gave them: bindings are still
  /// `{"@path": ...}` and children still ids.
  JsonMap get data => node.context!.componentModel.properties;

  /// Reads and writes the surface's data model, from this component's scope
  /// (a list template's item, or the root).
  DataContext get dataContext => node.context!.dataContext;
}

/// Builds the widget for one component.
typedef CatalogWidgetBuilder = Widget Function(CatalogItemContext itemContext);

/// A component the JSON screens can use: its name, the schema of its
/// properties, and the builder that turns them into a widget.
///
/// [implementation] is what the A2UI catalog (see `vitalloop_catalog.dart`)
/// registers with a2ui_flutter.
class CatalogItem {
  /// Creates a component named [name].
  ///
  /// [dataSchema] describes the component's own properties. It is completed
  /// with the `component` name and an optional `weight` unless
  /// [schemaIsComplete] says it already is a full A2UI component schema.
  CatalogItem({
    required this.name,
    required this.dataSchema,
    required this.widgetBuilder,
    this.description,
    this.exampleData = const [],
    this.isImplicitlyFlexible = false,
    this.schemaIsComplete = false,
  });

  /// The component's type name in the JSON, e.g. "IconBadge".
  final String name;

  /// The JSON schema of the component's properties.
  final Schema dataSchema;

  /// Builds the component's widget.
  final CatalogWidgetBuilder widgetBuilder;

  /// What the component is, in a sentence, for the catalog screen. When
  /// `null`, the [dataSchema]'s own description is shown.
  final String? description;

  /// Example screens (A2UI component lists as JSON text) that show the
  /// component, for the catalog screen and the tests.
  final List<String Function()> exampleData;

  /// Whether a Row or Column gives the component a share of the free space
  /// even without a `weight` (inputs that want all the width they can get).
  final bool isImplicitlyFlexible;

  /// Whether [dataSchema] is already a full component schema.
  final bool schemaIsComplete;

  /// The schema a component of this type must follow in an A2UI message.
  late final Schema componentSchema = schemaIsComplete
      ? dataSchema
      : Schema.fromMap({
          ...dataSchema.value,
          'type': 'object',
          'properties': {
            'component': {'const': name},
            ...?(dataSchema.value['properties'] as Map?)
                ?.cast<String, Object?>(),
            'weight': {'type': 'number'},
          },
          'required': [
            'component',
            ...?(dataSchema.value['required'] as List?)?.cast<String>(),
          ],
        });

  /// The schema the app checks a component of this type against: the
  /// [componentSchema] without its limits on property values (see
  /// [lenientComponentSchema]).
  ///
  /// The A2UI processor drops a whole screen when one component breaks its
  /// schema. The widgets cope with a value that is off (an unknown icon name
  /// shows a placeholder icon, a number shows as text), so one such value in
  /// what the LLM wrote must not cost the user the screen.
  late final Schema renderedSchema = lenientComponentSchema(componentSchema);

  /// The component as a2ui_flutter renders it, checked against
  /// [renderedSchema].
  late final ComponentImplementation implementation = _implement(
    renderedSchema,
  );

  /// The component checked against the full [componentSchema], for tests
  /// that hold the server's screens to what the catalog documents.
  late final ComponentImplementation strictImplementation = _implement(
    componentSchema,
  );

  ComponentImplementation _implement(Schema schema) => ComponentImplementation(
    name: name,
    schema: schema,
    builder: (context, node, props, buildChild) => widgetBuilder(
      CatalogItemContext(
        buildContext: context,
        node: node,
        props: props,
        buildChild: buildChild,
      ),
    ),
  );
}

/// The shared A2UI types whose shape the renderer relies on: a property of
/// one of these keeps its schema in [lenientComponentSchema].
const List<String> _keptTypes = [
  '/ChildList',
  '/Child',
  '/ComponentId',
  '/Action',
  '/Checkable',
  '/CheckRule',
  '/DynamicBoolean',
];

/// The shared A2UI types of a value that may be a literal, a binding or a
/// function call.
const List<String> _dynamicTypes = [
  '/DynamicString',
  '/DynamicNumber',
  '/DynamicStringList',
  '/DynamicValue',
  '/DataBinding',
];

/// The shared A2UI type a property [schema] points at, or `null`.
String? _sharedType(Map<Object?, Object?> schema) =>
    switch (schema[r'$ref'] ?? schema['commonTypesRef']) {
      final String ref => ref,
      _ => null,
    };

/// Whether a property [schema] takes a literal, a binding or a call.
bool _isDynamic(Object? schema) {
  if (schema is! Map) return false;
  final String? type = _sharedType(schema);
  if (type != null && _dynamicTypes.any(type.endsWith)) return true;
  if (schema['properties'] case {'@path': _}) return true;
  for (final key in const ['oneOf', 'anyOf', 'allOf']) {
    if (schema[key] case final List<Object?> branches) {
      if (branches.any(_isDynamic)) return true;
    }
  }
  return false;
}

/// A property [schema] without its limits on values.
Object? _lenientProperty(Object? schema) {
  if (schema is! Map) return schema;
  final String? type = _sharedType(schema);
  if (type != null && _keptTypes.any(type.endsWith)) return schema;
  final JsonMap description = {
    if (schema['description'] case final String text) 'description': text,
  };
  // Any literal, binding or call: the widget shows what it can.
  if (_isDynamic(schema)) {
    return {...CommonSchemasV1.dynamicValue.value, ...description};
  }
  // A plain value: anything goes, but the shape of an object or a list
  // stays, for the bindings and child references inside it.
  return {
    ...description,
    if (schema['properties'] case final Map<Object?, Object?> properties)
      'properties': {
        for (final MapEntry<Object?, Object?> entry in properties.entries)
          entry.key: _lenientProperty(entry.value),
      },
    if (schema['items'] case final Object items)
      'items': _lenientProperty(items),
  };
}

/// One object of a component schema (the schema itself, or a branch of its
/// `allOf`) without its limits on values.
JsonMap _lenientObject(Map<Object?, Object?> schema) => {
  for (final MapEntry<Object?, Object?> entry in schema.entries)
    if (entry.key == 'properties' && entry.value is Map)
      'properties': {
        for (final MapEntry<Object?, Object?> property
            in (entry.value! as Map).entries)
          // The type name is what makes it this component.
          property.key: property.key == 'component'
              ? property.value
              : _lenientProperty(property.value),
      }
    else if (entry.key == 'required')
      'required': ['component']
    else if (entry.key == 'allOf' && entry.value is List)
      'allOf': [
        for (final Object? branch in entry.value! as List)
          branch is Map && _sharedType(branch) == null
              ? _lenientObject(branch)
              : branch,
      ]
    else if (entry.key != 'additionalProperties' &&
        entry.key != 'unevaluatedProperties')
      '${entry.key}': entry.value,
};

/// A copy of the component [schema] that accepts any value for a property:
/// no enums, required properties or fixed types, and any literal where a
/// binding may stand.
///
/// What the renderer needs to know stays: the component's type name, which
/// properties are child references, actions and checks, and which hold
/// bindings.
Schema lenientComponentSchema(Schema schema) =>
    Schema.fromMap(_lenientObject(schema.value));

/// Schemas for properties that may be a literal or a data-model binding
/// (`{"@path": ...}`) or a function call (`{"@call": ...}`), in the A2UI
/// v1.0 shapes.
abstract final class A2uiSchemas {
  static Schema _described(Schema schema, String? description) =>
      description == null
      ? schema
      : Schema.fromMap({...schema.value, 'description': description});

  /// A string, or a binding or call that gives one.
  static Schema stringReference({
    String? description,
    List<String>? enumValues,
  }) => enumValues == null
      ? _described(CommonSchemasV1.dynamicString, description)
      : S.combined(
          description: description,
          oneOf: [
            S.string(enumValues: enumValues),
            CommonSchemasV1.dataBinding,
            CommonSchemasV1.functionCall,
          ],
        );

  /// A number, or a binding or call that gives one.
  static Schema numberReference({String? description}) =>
      _described(CommonSchemasV1.dynamicNumber, description);

  /// A list of strings, or a binding or call that gives one.
  static Schema stringArrayReference({String? description}) =>
      _described(CommonSchemasV1.dynamicStringList, description);

  /// A list of [items], or a binding to one.
  static Schema listOrReference({String? description, Schema? items}) =>
      S.combined(
        description: description,
        oneOf: [
          S.list(items: items),
          CommonSchemasV1.dataBinding,
        ],
      );

  /// A binding to a value in the data model: `{"@path": ...}`.
  static Schema dataBindingSchema() => CommonSchemasV1.dataBinding;
}
