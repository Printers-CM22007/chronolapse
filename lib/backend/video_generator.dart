import 'package:chronolapse/backend/generator_options.dart';
import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/backend/video_compiler.dart';
import 'package:opencv_dart/opencv.dart' as cv2;

class VideoGenerator {
  late VideoCompiler compiler;
  final GeneratorOptions options;

  VideoGenerator(this.options);

  void generateVideoFromTimelapse(String projectName) async {
    final projectData = await TimelapseStore.getProject(projectName);
    final List<String> frameUUIDs = projectData.data.metaData.frames;

    final referenceFrameUuid = projectData.data.knownFrameTransforms.frames[0];
    final referenceFrame = await TimelapseFrame.fromExisting(
        projectData.projectName(), referenceFrameUuid);

    final referenceImg = cv2.imread(referenceFrame.getFramePng().path);
    compiler = VideoCompiler(options.destination, options.codec, options.fps,
        referenceImg.width, referenceImg.height);

    for (var uuid in frameUUIDs) {
      final frame = await TimelapseFrame.fromExisting(projectName, uuid);
      final transform =
          await ImageTransformer.findHomography(projectData, frame);

      final resultingFrame = await ImageTransformer.applyHomography(
          referenceFrame.getFramePng(), transform!);
      if (resultingFrame.width != referenceImg.width ||
          resultingFrame.height != referenceImg.height) {
        throw Exception(
            "Timelapse: $projectName contained frames with different sizes");
      }

      await compiler.WriteFrame(resultingFrame);
    }

    compiler.Finish();
  }
}
