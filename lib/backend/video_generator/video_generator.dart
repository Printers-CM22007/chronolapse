import 'dart:io';

import 'package:chronolapse/backend/video_generator/generator_options.dart';
import 'package:chronolapse/backend/video_generator/video_compiler.dart';
import 'package:flutter/services.dart';

class VideoGenerator {
  late VideoCompiler compiler;
  final GeneratorOptions options;

  VideoGenerator(this.options);

  // VideoCompiler is currently cooked because cv.VideoWriter doesn't work on android :'(
  // so for now, it will just place cat_video.mp4 into /data/data/com.example.chronolapse/files/timelapse.mp4
  Future<void> generateVideoFromTimelapse(String projectName) async {
    /*final projectData = await TimelapseStore.getProject(projectName);
    final List<String> frameUUIDs = projectData.data.metaData.frames;

    final referenceFrameUuid = projectData.data.knownFrameTransforms.frames[0];
    final referenceFrame = await TimelapseFrame.fromExisting(projectData.projectName(), referenceFrameUuid);

    final referenceImg = cv2.imread(referenceFrame.getFramePng().path);
    compiler = VideoCompiler(options.destination, options.codec, options.fps, referenceImg.width, referenceImg.height);

    for (var uuid in frameUUIDs) {
      final frame = await TimelapseFrame.fromExisting(projectName, uuid);
      final transform = await ImageTransformer.findHomography(projectData, frame);

      final h = await ImageTransformer.applyHomography(referenceFrame.getFramePng(), transform!);
      final resultingFrame = cv2.transpose(h);
      if (resultingFrame.width != referenceImg.width || resultingFrame.height != referenceImg.height) {
        throw Exception("Timelapse: $projectName contained frames with different sizes");
      }

      await compiler.WriteFrame(resultingFrame);
    }

    compiler.Finish();*/

    final cat = await rootBundle.load("assets/cat_video.mp4");
    final bytes = cat.buffer.asUint8List();

    final file = File("/data/data/com.example.chronolapse/files/timelapse.mp4");
    await file.writeAsBytes(bytes);
  }
}
