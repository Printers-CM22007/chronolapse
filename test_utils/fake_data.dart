import 'dart:io';
import 'dart:math';

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/ui/models/pending_frame.dart';
import 'package:opencv_dart/opencv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// Create an empty image and save it to the given path
Future<File> saveBlankImage(
    String path, int width, int height, int channels) async {
  final image = img.Image(width: width, height: height, numChannels: channels);
  final jpgBytes = img.encodeJpg(image);

  final file = await File(path).create(recursive: true);
  file.writeAsBytes(jpgBytes, flush: true);

  return file;
}

List<FeaturePoint> getRandomFeaturePoints(int count) {
  var random = Random();
  return [
    for (var i = 0; i < count; i++)
      FeaturePoint(
          "Marker ${i + 1}",
          (255, 0, 0),
          FeaturePointPosition(
              random.nextDouble() * 1920.0, random.nextDouble() * 1080.0))
  ];
}

/// Create a fake project named `name` with `frameCount` dummy frames
Future<ProjectTimelapseData> createFakeProject(
    String name, int frameCount) async {
  final blankImageFile = await saveBlankImage(
      "${(await getTemporaryDirectory()).path}/blank.jpg", 1920, 1080, 3);
  assert(await blankImageFile.exists());
  final randomFeaturePoints = getRandomFeaturePoints(4);

  final project = (await TimelapseStore.createProject(name))!;

  final pendingFrame = PendingFrame(
      projectName: name,
      frameIndex: 0,
      temporaryImagePath: blankImageFile.path);

  // First frame
  if (frameCount > 0) {
    pendingFrame.featurePoints = randomFeaturePoints;
    pendingFrame.frameTransform = FrameTransform.baseFrame();
    await pendingFrame.saveInBackend(cleanupTemporaryImage: false);
  }

  // Subsequent frames
  pendingFrame.frameTransform = FrameTransform(
      transform: Homography.fromMatrix(Mat.eye(3, 3, MatType.CV_64FC1)),
      isKnown: false);
  for (var i = 1; i < frameCount; i++) {
    await pendingFrame.saveInBackend(cleanupTemporaryImage: false);
  }
  await project.reloadFromDisk();
  return project;
}
