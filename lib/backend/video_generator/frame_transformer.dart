import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:opencv_dart/opencv.dart' as cv;

Future<bool> transformFrames(String projectName, List<String> frames,
    String frameDir, Function(String) progressCallback) async {
  progressCallback("Transforming frames...");

  var lastUpdate = DateTime.now().millisecondsSinceEpoch;

  var i = 0;
  for (final frame in frames) {
    if (DateTime.now().millisecondsSinceEpoch - lastUpdate > 1000) {
      progressCallback("Transforming frames... $i/${frames.length}");
    }

    final frameData = await TimelapseFrame.fromExisting(projectName, frame);
    final transformed = await ImageTransformer.applyHomographyMat(
        frameData.getFramePng(), frameData.data.frameTransform.transform.getMatrix());
    await cv.imwriteAsync("$frameDir/$i.png", transformed);

    i += 1;
  }

  return true;
}
