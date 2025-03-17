import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:flutter/services.dart';

import '../settings_storage/settings_store.dart';
import '../timelapse_storage/timelapse_store.dart';

import 'package:opencv_dart/opencv.dart' as cv;

Future<void> testImageTransformerBreaksEverything() async {
  print("Starting image transformer test");

  await TimelapseStore.deleteAllProjects();
  await SettingsStore.deleteAllSettings();

  // * Create test project
  final testProject = (await TimelapseStore.createProject("testProject"))!;

  // * Create base frame to match against
  final baseFrame = TimelapseFrame.createNewWithData(
      testProject.projectName(), FrameData.initial(testProject.projectName()));
  baseFrame.data.frameTransform = FrameTransform.baseFrame();
  await baseFrame.saveFrameFromPngBytes(
      (await rootBundle.load("assets/image_transformer_test/f_0.jpg"))
          .buffer
          .asUint8List());

  // * Add frame to list of known frames
  testProject.data.knownFrameTransforms.frames
      .add(baseFrame.uuid()!); // uuid is known here as the frame has been saved
  await testProject.saveChanges();

  // * Create new frame to align
  final testFrame = TimelapseFrame.createNewWithData(
      testProject.projectName(), FrameData.initial(testProject.projectName()));
  await testFrame.saveFrameFromPngBytes(
      (await rootBundle.load("assets/image_transformer_test/fm_x.png"))
          .buffer
          .asUint8List());

  // * Align new frame
  final homography =
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
  }

  await TimelapseStore.deleteAllProjects();
}
