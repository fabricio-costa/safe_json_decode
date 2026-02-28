import 'package:safe_json/safe_json.dart';

void main() {
  // Simulating an API response where price comes as integer
  const apiResponse = '{"name": "Widget", "price": 29, "weight": 1.5}';

  final data = safeJsonDecode(apiResponse) as Map<String, dynamic>;

  // No more TypeError! price is always double
  print('Price: ${data['price'] as double}'); // 29.0
  print('Weight: ${data['weight'] as double}'); // 1.5
}
