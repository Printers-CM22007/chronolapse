import 'package:flutter/services.dart';

/// Test native method. Should return the counter + 1.
Future<int> testFunction(int counter) async {
  const MethodChannel platform =
      MethodChannel('com.example.chronolapse/channel');

  return await platform.invokeMethod("testFunction", {"count": 3}) as int;
}
