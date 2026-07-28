final class GenuxPointerValue {
  const GenuxPointerValue.missing() : exists = false, value = null;
  const GenuxPointerValue.found(this.value) : exists = true;

  final bool exists;
  final Object? value;
}

final class GenuxJsonPointer {
  GenuxJsonPointer._(this.source, this.segments);

  factory GenuxJsonPointer.parse(String source) {
    if (source.length > maxSourceLength) {
      throw const FormatException('JSON Pointer exceeds the length limit.');
    }
    if (source.isEmpty) {
      return GenuxJsonPointer._(source, const []);
    }
    if (!source.startsWith('/')) {
      throw FormatException(
        'JSON Pointer must be empty or start with "/": $source',
      );
    }

    final rawSegments = source.substring(1).split('/');
    if (rawSegments.length > maxSegments) {
      throw const FormatException('JSON Pointer has too many segments.');
    }
    final segments = rawSegments.map(_decodeSegment).toList();
    return GenuxJsonPointer._(source, List.unmodifiable(segments));
  }

  final String source;
  final List<String> segments;

  static const maxSourceLength = 4096;
  static const maxSegments = 128;
  static const maxSegmentLength = 512;

  GenuxPointerValue read(Object? document) {
    var current = document;
    for (final segment in segments) {
      if (current is Map) {
        if (!current.containsKey(segment)) {
          return const GenuxPointerValue.missing();
        }
        current = current[segment];
        continue;
      }

      if (current is List) {
        if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(segment)) {
          return const GenuxPointerValue.missing();
        }
        final index = int.tryParse(segment);
        if (index == null || index < 0 || index >= current.length) {
          return const GenuxPointerValue.missing();
        }
        current = current[index];
        continue;
      }

      return const GenuxPointerValue.missing();
    }
    return GenuxPointerValue.found(current);
  }
}

String _decodeSegment(String segment) {
  if (segment.length > GenuxJsonPointer.maxSegmentLength) {
    throw const FormatException(
      'JSON Pointer segment exceeds the length limit.',
    );
  }
  final output = StringBuffer();
  for (var index = 0; index < segment.length; index += 1) {
    final character = segment[index];
    if (character != '~') {
      output.write(character);
      continue;
    }
    if (index + 1 >= segment.length) {
      throw FormatException('Invalid JSON Pointer escape in "$segment".');
    }
    final escaped = segment[index + 1];
    if (escaped == '0') {
      output.write('~');
    } else if (escaped == '1') {
      output.write('/');
    } else {
      throw FormatException('Invalid JSON Pointer escape "~$escaped".');
    }
    index += 1;
  }
  return output.toString();
}
