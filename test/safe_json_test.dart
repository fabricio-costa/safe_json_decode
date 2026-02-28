import 'package:test/test.dart';
import 'package:safe_json/safe_json.dart';

void main() {
  group('safeJsonDecode', () {
    test('converts integers to doubles', () {
      final result = safeJsonDecode('{"price": 29}');
      expect(result['price'], isA<double>());
      expect(result['price'], equals(29.0));
    });

    test('preserves existing doubles', () {
      final result = safeJsonDecode('{"price": 29.99}');
      expect(result['price'], isA<double>());
      expect(result['price'], equals(29.99));
    });

    test('converts zero', () {
      final result = safeJsonDecode('{"x": 0}');
      expect(result['x'], isA<double>());
      expect(result['x'], equals(0.0));
    });

    test('converts negative integers', () {
      final result = safeJsonDecode('{"x": -42}');
      expect(result['x'], isA<double>());
      expect(result['x'], equals(-42.0));
    });

    test('converts top-level integer', () {
      final result = safeJsonDecode('42');
      expect(result, isA<double>());
      expect(result, equals(42.0));
    });

    test('converts integers in arrays', () {
      final result = safeJsonDecode('[1, 2, 3]');
      expect(result, everyElement(isA<double>()));
      expect(result, equals([1.0, 2.0, 3.0]));
    });

    test('converts nested integers', () {
      final result = safeJsonDecode('{"a": {"b": 5}}');
      expect(result['a']['b'], isA<double>());
      expect(result['a']['b'], equals(5.0));
    });

    test('does not affect non-numeric values', () {
      final result = safeJsonDecode(
        '{"a": null, "b": true, "c": "hello", "d": 5}',
      );
      expect(result['a'], isNull);
      expect(result['b'], isA<bool>());
      expect(result['c'], isA<String>());
      expect(result['d'], isA<double>());
    });

    test('works with reviver', () {
      final result = safeJsonDecode(
        '{"price": 5}',
        reviver: (key, value) {
          if (key == 'price' && value is double) {
            return value * 100; // cents
          }
          return value;
        },
      );
      expect(result['price'], equals(500.0));
    });

    test('reviver receives doubles not ints', () {
      final types = <Type>[];
      safeJsonDecode('{"x": 5}', reviver: (key, value) {
        if (key == 'x') types.add(value.runtimeType);
        return value;
      });
      expect(types, contains(double));
    });

    test('handles real-world API response', () {
      const json = '''
        {
          "id": 1,
          "name": "Widget",
          "price": 29,
          "weight": 1.5,
          "in_stock": true
        }
      ''';
      final data = safeJsonDecode(json);
      expect(data['id'], isA<double>());
      expect(data['price'], isA<double>());
      expect(data['weight'], isA<double>());
      expect(data['name'], isA<String>());
      expect(data['in_stock'], isA<bool>());
    });

    test('handles empty structures', () {
      expect(safeJsonDecode('{}'), equals({}));
      expect(safeJsonDecode('[]'), equals([]));
    });

    test('handles scientific notation', () {
      final result = safeJsonDecode('{"x": 5e2}');
      expect(result['x'], isA<double>());
      expect(result['x'], equals(500.0));
    });

    test('handles large integers', () {
      final result = safeJsonDecode('{"x": 9007199254740992}');
      expect(result['x'], isA<double>());
    });

    test('throws FormatException on invalid JSON', () {
      expect(() => safeJsonDecode('invalid'), throwsFormatException);
    });
  });

  group('SafeJsonCodec', () {
    test('decode converts integers to doubles', () {
      const codec = SafeJsonCodec();
      final result = codec.decode('{"price": 29}') as Map;
      expect(result['price'], isA<double>());
      expect(result['price'], equals(29.0));
    });

    test('encode works normally', () {
      const codec = SafeJsonCodec();
      final result = codec.encode({'price': 29.0});
      expect(result, equals('{"price":29.0}'));
    });
  });

  group('SafeJsonDecoder', () {
    test('convert returns doubles for integers', () {
      const decoder = SafeJsonDecoder();
      final result = decoder.convert('{"x": 5}') as Map;
      expect(result['x'], isA<double>());
    });
  });
}
