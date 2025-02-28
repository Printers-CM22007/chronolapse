import 'package:flutter/services.dart';

Future<int> testFunction(int counter) async {
  const MethodChannel platform =
      MethodChannel('com.example.chronolapse/channel');

  return await platform.invokeMethod("testFunction", {"count": 3}) as int;
}
