## 1.2.0

- Add README.md with problem description, API docs, and language comparison table
- Add example/safe_json_example.dart for pub.dev scoring
- Add `topics` to pubspec.yaml for discoverability
- Replace deprecated named `library safe_json;` with unnamed `library;`
- Document chunked conversion limitation on `SafeJsonDecoder`
- Add test for FormatException on invalid JSON input

## 1.0.0

- Initial release
- `safeJsonDecode()` — drop-in replacement for `jsonDecode` with int→double conversion
- `SafeJsonCodec` — codec variant for streaming/integration use cases
- `SafeJsonDecoder` — converter variant
