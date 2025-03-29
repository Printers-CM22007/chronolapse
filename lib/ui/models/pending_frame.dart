import 'dart:io';

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_metadata.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:flutter/material.dart';

class PendingFrame {
  final String projectName;
  final int frameIndex;
  String temporaryImagePath;
  List<FeaturePoint>? featurePoints;
  FrameTransform? frameTransform;

  PendingFrame(
      {required this.projectName,
      required this.frameIndex,
      required this.temporaryImagePath,
      this.featurePoints});

  Future<TimelapseFrame> saveInBackend() async {
    assert(frameTransform != null);
    assert(featurePoints != null);

    final project = await TimelapseStore.getProject(projectName);

    final frame = TimelapseFrame.createNewWithData(
        projectName,
        FrameData(
          metaData: FrameMetaData.initial(projectName),
          frameTransform: frameTransform!,
          featurePoints: featurePoints!,
        ));
    await frame.saveFrameFromPngFile(File(temporaryImagePath));

    // Cleanup temporary image
    File(temporaryImagePath).delete();

    return frame;
  }
}
