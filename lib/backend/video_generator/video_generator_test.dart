import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/video_generator/video_generator.dart';
import 'package:chronolapse/backend/video_generator/generator_options.dart';
import 'package:flutter/services.dart';

import '../settings_storage/settings_store.dart';
import '../timelapse_storage/timelapse_store.dart';

import 'package:opencv_dart/opencv.dart' as cv;
import 'package:path_provider/path_provider.dart';

Future<void> testVideoGenerator() async {
  print("Starting video generator test");

  await TimelapseStore.deleteAllProjects();
  await SettingsStore.deleteAllSettings();

  // * Create test project
  final testProject = (await TimelapseStore.createProject("testProject"))!;

  // * Create base frame to match against
  final baseFrame = TimelapseFrame.createNewWithData(
      testProject.projectName(), FrameData.initial(testProject.projectName()));
  baseFrame.data.frameTransform = FrameTransform(
      transform: Homography.fromMatrix(cv.Mat.eye(3, 3, cv.MatType.CV_64FC1)),
      isKnown: true);
  await baseFrame.saveFrameFromPngBytes(
      (await rootBundle.load("assets/image_transformer_test/f_0.jpg"))
          .buffer
          .asUint8List());

  testProject.data.knownFrameTransforms.frames
      .add(baseFrame.uuid()!);
  await testProject.saveChanges();

  // * Create new frames to align
  for(int i = 0; i < 60; i++) {
    final testFrame = TimelapseFrame.createNewWithData(
        testProject.projectName(), FrameData.initial(testProject.projectName()));
    await testFrame.saveFrameFromPngBytes(
        (await rootBundle.load("assets/image_transformer_test/fm_x.png"))
            .buffer
            .asUint8List());
  }


  // Align new frame
  /*final homography =
  await ImageTransformer.findHomography(testProject, testFrame);

  if (homography == null) {
    print("Failed to find homography");
    print("Would prompt user to manually align here");
  } else {
    print("Found image homography");

    for (final r in homography.vals) {
      print(r);
    }

    // Save transform
    testFrame.data.frameTransform = FrameTransform(
        transform: homography,
        isKnown: false); // isKnown false because this isn't user-aligned
    await testFrame.saveFrameDataOnly();
  }*/

  final cacheDir = await getTemporaryDirectory();
  print(cacheDir.path);
  //final generator = VideoGenerator(GeneratorOptions.defaultSettings("/data/data/com.example.chronolapse/cache/video.mp4"));
  //await generator.generateVideoFromTimelapse("testProject");

  final img = cv.Mat.create(rows: 100, cols: 100, r: 128, g: 128, b: 128, type: cv.MatType.CV_8SC(4));
  cv.imwrite("/data/data/com.example.chronolapse/cache/test.png", img);
  //cv.imwrite("${cacheDir.path}/test.png", img);
  print(cv.getBuildInformation());
  // !!!!!!!!!!!!!! if doesnt use cv.CAP_OPENCV_MJPEG cant read the fucking path
  final writer = cv.VideoWriter.fromFile("/data/data/com.example.chronolapse/cache/video.avi", "MJPG  ", 60, (100, 100));//, apiPreference: cv.CAP_OPENCV_MJPEG);
  if (!writer.isOpened) throw Exception("video writer failed to open");
  for(int i = 0; i < 100; i++) {
    writer.write(img);
  }
  writer.release();

  //final generator = VideoGenerator(GeneratorOptions.defaultSettings());
  //await generator.generateVideoFromTimelapse("testProject");

  await TimelapseStore.deleteAllProjects();
}