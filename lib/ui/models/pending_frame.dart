import 'dart:io';

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_metadata.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';

/// Represents a frame as it progresses from being taken to being saved to
/// the timelapse
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

  /// Saves the frame to the timelapse. Deletes the temporary image
  /// (`temporaryImagePath`) unless `cleanupTemporaryImage` is set to false.
  Future<TimelapseFrame> saveInBackend(
      {bool cleanupTemporaryImage = true}) async {
    assert(frameTransform != null);
    assert(featurePoints != null);

    final frame = TimelapseFrame.createNewWithData(
        projectName,
        FrameData(
          metaData: FrameMetaData.initial(projectName),
          frameTransform: frameTransform!,
          featurePoints: featurePoints!,
        ));
    await frame.saveFrameFromPngFile(File(temporaryImagePath));

    // Cleanup temporary image
    if (cleanupTemporaryImage) {
      File(temporaryImagePath).delete();
    }

    return frame;
  }
}
