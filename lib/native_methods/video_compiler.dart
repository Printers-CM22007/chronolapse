import 'package:flutter/services.dart';

Future<String?> compileVideo(String frameDir, int frameCount, String outputPath) async {
  const MethodChannel platform =
  MethodChannel('com.example.chronolapse/channel');

  final result = await platform.invokeMethod("compileVideo", {"frameDir": frameDir, "frameCount": frameCount, "outputPath": outputPath});
  if (result == null) {
    return null;
  }

  return result as String;
}
