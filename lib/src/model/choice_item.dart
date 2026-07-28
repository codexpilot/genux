import 'dart:collection';

final class GenuxChoiceItem {
  GenuxChoiceItem({
    required this.key,
    required this.label,
    this.disabled = false,
    this.description,
    this.group,
    this.icon,
    Map<String, Object?> meta = const {},
  }) : meta = UnmodifiableMapView(_freezeObject(meta)) {
    if (!_isNonNullJsonScalar(key)) {
      throw ArgumentError.value(key, 'key', 'Must be a non-null JSON scalar.');
    }
    if (!_isJsonObject(this.meta)) {
      throw ArgumentError.value(meta, 'meta', 'Must contain only JSON values.');
    }
  }

  factory GenuxChoiceItem.fromJson(Map<String, Object?> json) {
    const allowedKeys = {
      'key',
      'label',
      'disabled',
      'description',
      'group',
      'icon',
      'meta',
    };
    final unknown = json.keys.where((key) => !allowedKeys.contains(key));
    if (unknown.isNotEmpty) {
      throw FormatException('Unknown ChoiceItem field: ${unknown.first}.');
    }

    final key = json['key'];
    final label = json['label'];
    final disabled = json['disabled'] ?? false;
    final description = json['description'];
    final group = json['group'];
    final icon = json['icon'];
    final rawMeta = json['meta'] ?? const <String, Object?>{};

    if (!_isNonNullJsonScalar(key)) {
      throw const FormatException(
        'ChoiceItem.key must be a non-null JSON scalar.',
      );
    }
    if (label is! String) {
      throw const FormatException('ChoiceItem.label must be a string.');
    }
    if (disabled is! bool) {
      throw const FormatException('ChoiceItem.disabled must be a boolean.');
    }
    if (description != null && description is! String) {
      throw const FormatException('ChoiceItem.description must be a string.');
    }
    if (group != null && group is! String) {
      throw const FormatException('ChoiceItem.group must be a string.');
    }
    if (icon != null && icon is! String) {
      throw const FormatException('ChoiceItem.icon must be a string.');
    }
    if (rawMeta is! Map) {
      throw const FormatException('ChoiceItem.meta must be an object.');
    }

    return GenuxChoiceItem(
      key: key as Object,
      label: label,
      disabled: disabled,
      description: description as String?,
      group: group as String?,
      icon: icon as String?,
      meta: _stringMap(rawMeta, 'ChoiceItem.meta'),
    );
  }

  final Object key;
  final String label;
  final bool disabled;
  final String? description;
  final String? group;
  final String? icon;
  final Map<String, Object?> meta;

  Map<String, Object?> toJson() => {
    'key': key,
    'label': label,
    if (disabled) 'disabled': true,
    if (description != null) 'description': description,
    if (group != null) 'group': group,
    if (icon != null) 'icon': icon,
    if (meta.isNotEmpty) 'meta': meta,
  };
}

bool _isNonNullJsonScalar(Object? value) =>
    value is bool ||
    value is int ||
    (value is double && value.isFinite) ||
    value is String;

bool _isJsonObject(Map<String, Object?> value) =>
    value.values.every(_isJsonValue);

bool _isJsonValue(Object? value) {
  if (value == null || _isNonNullJsonScalar(value)) {
    return true;
  }
  if (value is List) {
    return value.every(_isJsonValue);
  }
  if (value is Map) {
    return value.entries.every(
      (entry) => entry.key is String && _isJsonValue(entry.value),
    );
  }
  return false;
}

Map<String, Object?> _stringMap(Map<Object?, Object?> value, String field) {
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw FormatException('$field keys must be strings.');
    }
    result[entry.key! as String] = entry.value;
  }
  return result;
}

Map<String, Object?> _freezeObject(Map<String, Object?> value) => {
  for (final entry in value.entries) entry.key: _freezeJson(entry.value),
};

Object? _freezeJson(Object? value, {int depth = 0, Set<Object>? ancestors}) {
  if (depth > 128) {
    throw ArgumentError('ChoiceItem metadata nesting exceeds the hard limit.');
  }
  if (value is List) {
    final seen = ancestors ?? Set<Object>.identity();
    if (!seen.add(value)) {
      throw ArgumentError('ChoiceItem metadata cannot contain cycles.');
    }
    final result = List<Object?>.unmodifiable(
      value.map((item) => _freezeJson(item, depth: depth + 1, ancestors: seen)),
    );
    seen.remove(value);
    return result;
  }
  if (value is Map) {
    final seen = ancestors ?? Set<Object>.identity();
    if (!seen.add(value)) {
      throw ArgumentError('ChoiceItem metadata cannot contain cycles.');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw ArgumentError('ChoiceItem metadata keys must be strings.');
      }
      result[key] = _freezeJson(entry.value, depth: depth + 1, ancestors: seen);
    }
    seen.remove(value);
    return Map<String, Object?>.unmodifiable(result);
  }
  return value;
}
