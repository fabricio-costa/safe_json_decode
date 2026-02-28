/// A drop-in replacement for `jsonDecode` that converts all JSON integers
/// to doubles, preventing `TypeError: type 'int' is not a subtype of type 'double'`.
///
/// JSON (RFC 8259) makes no distinction between `5` and `5.0` — both are "number".
/// Dart's `jsonDecode` preserves the int/double distinction, which causes runtime
/// crashes when a backend returns `29` for a field your model expects as `double`.
///
/// Usage:
/// ```dart
/// import 'package:safe_json/safe_json.dart';
///
/// // Instead of: jsonDecode(response.body)
/// final data = safeJsonDecode(response.body);
/// // data['price'] is now guaranteed to be double, even if the JSON had "price": 29
/// ```
library;

import 'dart:convert';

/// Decodes a JSON string with all numbers converted to [double].
///
/// This is equivalent to:
/// ```dart
/// jsonDecode(source, reviver: (_, v) => v is int ? v.toDouble() : v)
/// ```
///
/// The [reviver] parameter, if provided, is called **after** the int→double
/// conversion, so it always receives doubles for numeric values.
dynamic safeJsonDecode(
  String source, {
  Object? Function(Object? key, Object? value)? reviver,
}) {
  return jsonDecode(source, reviver: (key, value) {
    if (value is int) value = value.toDouble();
    if (reviver != null) return reviver(key, value);
    return value;
  });
}

/// A [JsonCodec] that converts all JSON integers to doubles on decode.
///
/// Use this when you need a codec instance (e.g., for streaming or
/// when integrating with APIs that accept a [Codec]).
///
/// ```dart
/// final codec = SafeJsonCodec();
/// final data = codec.decode('{"price": 29}');
/// print(data['price'] is double); // true
/// ```
class SafeJsonCodec extends Codec<Object?, String> {
  const SafeJsonCodec();

  @override
  Converter<String, Object?> get decoder => const SafeJsonDecoder();

  @override
  Converter<Object?, String> get encoder => const JsonEncoder();
}

/// A [Converter] that decodes JSON strings with all numbers as doubles.
///
/// Note: This converter only supports single-string conversion via [convert].
/// Chunked conversion (via `startChunkedConversion`) is not supported.
/// For streaming use cases, apply the int-to-double reviver to a standard
/// [JsonDecoder] with chunked support.
class SafeJsonDecoder extends Converter<String, Object?> {
  const SafeJsonDecoder();

  @override
  Object? convert(String input) => safeJsonDecode(input);
}
