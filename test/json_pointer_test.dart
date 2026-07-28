import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  test('reads objects, lists, and escaped RFC 6901 segments', () {
    final state = {
      'items': [
        {
          'a/b': {'tilde~key': 7},
        },
      ],
    };

    final result = GenuxJsonPointer.parse(
      '/items/0/a~1b/tilde~0key',
    ).read(state);

    expect(result.exists, isTrue);
    expect(result.value, 7);
  });

  test('distinguishes a missing value from explicit null', () {
    final state = {'present': null};

    expect(GenuxJsonPointer.parse('/present').read(state).exists, isTrue);
    expect(GenuxJsonPointer.parse('/missing').read(state).exists, isFalse);
  });

  test('rejects invalid pointer escapes', () {
    expect(() => GenuxJsonPointer.parse('/bad~2escape'), throwsFormatException);
  });
}
