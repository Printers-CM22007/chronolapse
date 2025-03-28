
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';

Future<bool> transformFrames(String projectName, List<String> frames, String frameDir, Function(String) progressCallback) async {
  progressCallback("Transforming frames...");

  var lastUpdate = DateTime.now().millisecondsSinceEpoch;

  var i = 0;
  for (final frame in frames) {
    i += 1;
    if (DateTime.now().millisecondsSinceEpoch - lastUpdate > 1000) {
      progressCallback("Transforming frames... $i/${frames.length}");
    }

    final frameData = await TimelapseFrame.fromExisting(projectName, frame);
    // frameData.
  }

  throw UnimplementedError();
}