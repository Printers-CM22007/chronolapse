import 'dart:io';
import 'dart:math';

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/ui/models/pending_frame.dart';
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// Create an image filled with random pixels and save it to the given path
Future<File> saveRandomImage(
    String path, int width, int height, int channels) async {
  final image = img.Image(width: width, height: height, numChannels: channels);
  final random = Random();

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      image.setPixel(
          x,
          y,
          img.ColorRgb8(
              random.nextInt(256), random.nextInt(256), random.nextInt(256)));
    }
  }

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
Future<void> createFakeProject(String name, int frameCount) async {
  final randomImageFile = await saveRandomImage(
      "${(await getTemporaryDirectory()).path}/blank.jpg", 1920, 1080, 3);
  assert(await randomImageFile.exists());
  final randomFeaturePoints = getRandomFeaturePoints(4);

  await TimelapseStore.createProject(name);

  final pendingFrame = PendingFrame(
      projectName: name,
      frameIndex: 0,
      temporaryImagePath: randomImageFile.path);

  // First frame
  if (frameCount > 0) {
    pendingFrame.featurePoints = randomFeaturePoints;
    pendingFrame.frameTransform = FrameTransform.baseFrame();
    final frame =
        await pendingFrame.saveInBackend(cleanupTemporaryImage: false);

    // Mark as known frame
    final project = await TimelapseStore.getProject(name);
    project.data.knownFrameTransforms.frames.add(frame.uuid()!);
    await project.saveChanges();
  }

  // Subsequent frames
  pendingFrame.frameTransform = FrameTransform(
      transform: Homography.fromMatrix(Mat.eye(3, 3, MatType.CV_64FC1)),
      isKnown: false);
  for (var i = 1; i < frameCount; i++) {
    await pendingFrame.saveInBackend(cleanupTemporaryImage: false);
  }
}
