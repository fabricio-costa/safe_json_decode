# safe_json_decode

[![pub package](https://img.shields.io/pub/v/safe_json_decode.svg)](https://pub.dev/packages/safe_json_decode)

A drop-in replacement for `jsonDecode` that converts all JSON integers to doubles,
preventing `TypeError: type 'int' is not a subtype of type 'double'`.

## The problem

JSON ([RFC 8259](https://datatracker.ietf.org/doc/html/rfc8259)) makes no distinction between `5` and `5.0` — both are just "number". Dart's `jsonDecode` preserves the int/double distinction based on notation, which causes runtime crashes when a backend returns `29` for a field your model expects as `double`.

```dart
// Standard jsonDecode — crashes at runtime
final data = jsonDecode('{"price": 29}');
final double price = data['price'] as double; // TypeError!
```

This is especially common with REST APIs where the same field may return `29` or `29.0` depending on the value.

### How other languages handle this

| Language   | `jsonDecode('5')` type | Cast to double needed? |
|------------|----------------------|----------------------|
| Python     | `int`                | No (`int + float` works) |
| JavaScript | `number`             | No (single type)     |
| Go         | `float64`            | No (default)         |
| Swift      | `Double`             | No (Codable)         |
| **Dart**   | **`int`**            | **Yes — crashes**    |

## Usage

```dart
import 'package:safe_json_decode/safe_json_decode.dart';

// Instead of: jsonDecode(response.body)
final data = safeJsonDecode(response.body);
final double price = data['price'] as double; // works!
```

## API

### `safeJsonDecode(String source, {reviver})`

Drop-in replacement for `jsonDecode`. All integer values in the JSON are converted to doubles. The optional `reviver` is called **after** the int-to-double conversion.

### `SafeJsonCodec`

A `Codec<Object?, String>` for use with streaming APIs or anywhere a codec instance is needed.

```dart
const codec = SafeJsonCodec();
final data = codec.decode('{"price": 29}');
print(data['price'] is double); // true
```

### `SafeJsonDecoder`

A `Converter<String, Object?>` that decodes JSON with int-to-double conversion. Note: chunked conversion via `startChunkedConversion` is not supported — use `convert()` directly or `safeJsonDecode()` for single-string inputs.

## Why this exists

This package was created after the Dart team declined [RFC #62776](https://github.com/dart-lang/sdk/issues/62776), a proposal to add a `JsonNumericMode` option to the SDK's `jsonDecode`. The team considers the int/double distinction a deliberate design choice (see [sdk#55499](https://github.com/dart-lang/sdk/issues/55499)).

While code generation tools like `json_serializable` and `freezed` can handle this, many projects use manual JSON parsing or need a simple fix without adding a build step.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
