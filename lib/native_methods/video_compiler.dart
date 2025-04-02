import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/settings_options.dart';
import 'package:flutter/services.dart';

/// Native Method. Compiles a timelapse from frames in `frameDir` into a
/// timelapse in `outputPath`. Returns the `outputPath` if successful.
Future<String?> compileVideo(String frameDir, int frameCount, String outputPath,
    String projectName) async {
  const MethodChannel platform =
      MethodChannel('com.example.chronolapse/channel');

  final result = await platform.invokeMethod("compileVideo", {
    "frameDir": frameDir,
    "frameCount": frameCount,
    "outputPath": outputPath,
    "frameRate": fpsSetting.withProject(ProjectName(projectName)).getValue(),
    "bitRate": bitRateSetting.withProject(ProjectName(projectName)).getValue(),
  });
  if (result == null) {
    return null;
  }

  return result as String;
}
