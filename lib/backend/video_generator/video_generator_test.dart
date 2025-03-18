import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:flutter/services.dart';

import '../settings_storage/settings_store.dart';
import '../timelapse_storage/timelapse_store.dart';

import 'package:opencv_dart/opencv.dart' as cv;

Future<void> testVideoGenerator() async {
  print("Starting video generator test");

  await TimelapseStore.deleteAllProjects();
  await SettingsStore.deleteAllSettings();

  final testProject = (await TimelapseStore.createProject("testProject"))!;

  await TimelapseStore.deleteAllProjects();
}
