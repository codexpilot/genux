enum GenuxValueKind {
  any,
  boolean,
  integer,
  number,
  string,
  jsonScalar,
  object,
  list,
  choiceItem,
}

final class GenuxValueType {
  const GenuxValueType(this.kind, {this.nullable = false, this.itemType})
    : assert(kind == GenuxValueKind.list || itemType == null);

  static const any = GenuxValueType(GenuxValueKind.any, nullable: true);
  static const boolean = GenuxValueType(GenuxValueKind.boolean);
  static const nullableBoolean = GenuxValueType(
    GenuxValueKind.boolean,
    nullable: true,
  );
  static const integer = GenuxValueType(GenuxValueKind.integer);
  static const number = GenuxValueType(GenuxValueKind.number);
  static const string = GenuxValueType(GenuxValueKind.string);
  static const nullableString = GenuxValueType(
    GenuxValueKind.string,
    nullable: true,
  );
  static const jsonScalar = GenuxValueType(GenuxValueKind.jsonScalar);
  static const nullableJsonScalar = GenuxValueType(
    GenuxValueKind.jsonScalar,
    nullable: true,
  );
  static const object = GenuxValueType(GenuxValueKind.object);
  static const nullableObject = GenuxValueType(
    GenuxValueKind.object,
    nullable: true,
  );
  static const choiceItem = GenuxValueType(GenuxValueKind.choiceItem);
  static const choiceItems = GenuxValueType(
    GenuxValueKind.list,
    itemType: choiceItem,
  );

  final GenuxValueKind kind;
  final bool nullable;
  final GenuxValueType? itemType;

  bool accepts(Object? value) {
    if (value == null) {
      return nullable;
    }

    return switch (kind) {
      GenuxValueKind.any => _isJsonValue(value),
      GenuxValueKind.boolean => value is bool,
      GenuxValueKind.integer => value is int,
      GenuxValueKind.number => _isJsonNumber(value),
      GenuxValueKind.string => value is String,
      GenuxValueKind.jsonScalar => _isJsonScalar(value),
      GenuxValueKind.object => _isJsonObject(value),
      GenuxValueKind.list =>
        value is List<Object?> &&
            value.every((item) => itemType?.accepts(item) ?? true) &&
            (itemType?.kind != GenuxValueKind.choiceItem ||
                _hasUniqueChoiceKeys(value)),
      GenuxValueKind.choiceItem => _isChoiceItem(value),
    };
  }

  String get displayName {
    final base = switch (kind) {
      GenuxValueKind.any => 'JSON value',
      GenuxValueKind.boolean => 'boolean',
      GenuxValueKind.integer => 'integer',
      GenuxValueKind.number => 'number',
      GenuxValueKind.string => 'string',
      GenuxValueKind.jsonScalar => 'JSON scalar',
      GenuxValueKind.object => 'object',
      GenuxValueKind.list => 'list<${itemType?.displayName ?? 'JSON value'}>',
      GenuxValueKind.choiceItem => 'ChoiceItem',
    };
    return nullable ? '$base?' : base;
  }
}

bool _isJsonScalar(Object? value) =>
    value == null || value is bool || _isJsonNumber(value) || value is String;

bool _isJsonNumber(Object? value) =>
    value is int || (value is double && value.isFinite);

bool _isJsonObject(Object? value) {
  if (value is! Map) {
    return false;
  }
  return value.entries.every(
    (entry) => entry.key is String && _isJsonValue(entry.value),
  );
}

bool _isJsonValue(Object? value) {
  if (_isJsonScalar(value)) {
    return true;
  }
  if (value is List) {
    return value.every(_isJsonValue);
  }
  return _isJsonObject(value);
}

bool _isChoiceItem(Object? value) {
  if (value is! Map) {
    return false;
  }

  final key = value['key'];
  final label = value['label'];
  final disabled = value['disabled'];
  final description = value['description'];
  final group = value['group'];
  final icon = value['icon'];
  final meta = value['meta'];

  return key != null &&
      _isJsonScalar(key) &&
      label is String &&
      (disabled == null || disabled is bool) &&
      (description == null || description is String) &&
      (group == null || group is String) &&
      (icon == null || icon is String) &&
      (meta == null || _isJsonObject(meta)) &&
      value.keys.every(
        (key) =>
            key == 'key' ||
            key == 'label' ||
            key == 'disabled' ||
            key == 'description' ||
            key == 'group' ||
            key == 'icon' ||
            key == 'meta',
      );
}

bool _hasUniqueChoiceKeys(List<Object?> values) {
  final keys = <Object?>{};
  for (final value in values) {
    if (value is! Map || !keys.add(value['key'])) {
      return false;
    }
  }
  return true;
}
