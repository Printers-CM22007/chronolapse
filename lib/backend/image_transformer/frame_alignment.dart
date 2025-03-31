import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:opencv_dart/opencv.dart' as cv;

/// Estimate where the feature points would end up on an automatically aligned
/// frame by applying the frame transform to the reference feature points
/// points
List<FeaturePoint> getFeaturePointsForAutomaticallyAlignedFrame(
    List<FeaturePoint> referenceFeaturePoints, FrameTransform frameTransform) {
  // TODO(Benny) Ask for help from Rob on this I think it's broken
  // Only affects display of feature points in editor page

  FeaturePoint transformPoint(cv.Mat homography, FeaturePoint point) {
    final src = cv.Mat.fromList(
        1, 1, cv.MatType.CV_64FC2, [point.position.x, point.position.y]);
    final cv.Vec2d p = cv.perspectiveTransform(src, homography).at(0, 0);

    return FeaturePoint(
        point.label, point.color, FeaturePointPosition(p.val[0], p.val[1]));
  }

  final m = frameTransform.transform.getMatrix();

  return [for (final p in referenceFeaturePoints) transformPoint(m, p)];
}

/// Helper class to get a frame's alignment
class FrameAlignment {
  final FrameTransform frameTransform;
  final List<FeaturePoint> featurePoints;

  FrameAlignment({required this.frameTransform, required this.featurePoints});

  /// Frame alignment for the first frame
  static FrameAlignment baseFrame(List<FeaturePoint> featurePoints) {
    return FrameAlignment(
        frameTransform: FrameTransform.baseFrame(),
        featurePoints: featurePoints);
  }

  /// Calculate automatic frame alignment
  /// May return `null` if the automatic alignment fails (homography returned by
  /// `findHomography` is `null`.
  static Future<FrameAlignment?> automatic(
    String projectName,
    String frameImagePath,
  ) async {
    final project = await TimelapseStore.getProject(projectName);

    final homography =
        await ImageTransformer.findHomography(project, frameImagePath);

    if (homography == null) {
      // Automatic alignment failed
      return null;
    }

    final frameTransform = FrameTransform.autoGenerated(homography);

    // Get feature points
    final featurePoints = getFeaturePointsForAutomaticallyAlignedFrame(
        (await project.getFrameWithIndex(0)).data.featurePoints,
        frameTransform);

    return FrameAlignment(
        frameTransform: frameTransform, featurePoints: featurePoints);
  }

  /// Calculate manual frame alignment
  static Future<FrameAlignment> manual(
      String projectName, List<FeaturePoint> featurePoints) async {
    final project = await TimelapseStore.getProject(projectName);
    final referenceFeaturePoints =
        (await project.getFrameWithIndex(0)).data.featurePoints;

    return FrameAlignment(
        frameTransform: await FrameTransform.fromFeaturePoints(
            featurePoints, referenceFeaturePoints),
        featurePoints: featurePoints);
  }
}
