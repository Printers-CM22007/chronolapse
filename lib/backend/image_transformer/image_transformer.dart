import 'dart:io';
import 'dart:math';

import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:opencv_dart/opencv.dart' as cv;

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);
}

class ImageTransformer {
  /// Finds a homography for the specified frame and saves it to the frame.
  /// Returns a boolean representing success.
  ///
  /// Requires `TimelapseData.knownFrameTransforms.frames` to contain at least
  /// one reference frame (and, of course, for that frame's `FrameData` to have
  /// its `frameTransform` set with `frameTransform.isKnown` set to true). This
  /// should always be the case, however, as the first frame should have its
  /// `frameTransform` set to the identity matrix with `isKnown` set to true.
  static Future<bool> findAndSaveHomography(
      ProjectTimelapseData projectData, TimelapseFrame frame) async {
    if (frame.data.frameTransform.isKnown ?? false) {
      throw Exception("Cannot overwrite a know user-verified homography for"
          " frame '${frame.uuid()}' with a automatically-generated one");
    }

    final homography =
        await findHomography(projectData, frame.getFramePng().path);

    if (homography == null) {
      return false;
    }

    frame.data.frameTransform = FrameTransform.autoGenerated(homography);

    return true;
  }

  /// Finds a homography for the specified frame.
  ///
  /// Requires `TimelapseData.knownFrameTransforms.frames` to contain at least
  /// one reference frame (and, of course, for that frame's `FrameData` to have
  /// its `frameTransform` set with `frameTransform.isKnown` set to true). This
  /// should always be the case, however, as the first frame should have its
  /// `frameTransform` set to the identity matrix with `isKnown` set to true.
  static Future<Homography?> findHomography(
      ProjectTimelapseData projectData, String framePath) async {
    // Ensure at least one reference frame exists
    if (projectData.data.knownFrameTransforms.frames.isEmpty) {
      throw Exception("Cannot transform image without any known transforms");
    }

    // if (frame.data.frameTransform?.isKnown ?? false) {
    //   print("!! Attempted to find a homography automatically for a frame with a"
    //       " known user-verified homography. This was probably done in error.");
    // }

    // Get which frame to try to align to
    // TODO: Apply better heuristics to this
    final referenceFrameUuid = projectData.data.knownFrameTransforms.frames[0];

    // Get reference frame
    final referenceFrame = await TimelapseFrame.fromExisting(
        projectData.projectName(), referenceFrameUuid);
    final referenceImg =
        await cv.imreadAsync(referenceFrame.getFramePng().path);
    final referenceGray =
        await cv.cvtColorAsync(referenceImg, cv.COLOR_BGR2GRAY);

    // Ensure frame is a reference frame
    if (!referenceFrame.data.frameTransform.isKnown) {
      throw Exception("Reference frame '${referenceFrame.uuid()}' marked as "
          "having known transform in project '${projectData.projectName()}' "
          "however it is not present in the frame data");
    }

    // Get homography from the initial frame (absolute truth) to the reference
    // frame
    final referenceHomography =
        referenceFrame.data.frameTransform.transform.getMatrix();

    // Get frame needing a homography
    final img = await cv.imreadAsync(framePath);
    final imgGray = await cv.cvtColorAsync(img, cv.COLOR_BGR2GRAY);

    // Have to provide mask including all pixels as mask argument is
    // non-nullable (WHY?!)
    final mask =
        cv.Mat.ones(img.rows, img.cols, cv.MatType.CV_8UC1).multiply(255);

    // Get keypoints
    final orb = cv.ORB.create();
    final (kpRef, dscRef) =
        await orb.detectAndComputeAsync(referenceGray, mask);
    final (kpImg, dscImg) = await orb.detectAndComputeAsync(imgGray, mask);

    // Find and sort matches
    final bf = cv.BFMatcher.create(type: cv.NORM_HAMMING, crossCheck: true);
    final matches = (await bf.matchAsync(dscRef, dscImg)).toList();
    matches.sort((a, b) => a.distance.compareTo(b.distance));

    final numGoodMatches = max<int>((matches.length / 5).toInt(), 12);
    final goodMatches = matches.sublist(0, numGoodMatches);

    // Two lists of matched points
    final srcPts = cv.Mat.from2DList(
        goodMatches.map((e) => [kpRef[e.queryIdx].x, kpRef[e.queryIdx].y]),
        cv.MatType.CV_64FC1);
    final dstPts = cv.Mat.from2DList(
        goodMatches.map((e) => [kpImg[e.trainIdx].x, kpImg[e.trainIdx].y]),
        cv.MatType.CV_64FC1);

    // Get the homography
    final (homography, _) = await cv.findHomographyAsync(dstPts, srcPts,
        method: cv.RANSAC, ransacReprojThreshold: 5.0);

    // TODO: Ensure homography is sensible

    // Apply the reference's homography so that instead of the homography
    // being reference -> current frame it's initial frame (absolute truth ->
    // current frame
    return Homography.fromMatrix(await cv.gemmAsync(referenceHomography,
        homography, 1.0, cv.Mat.zeros(3, 3, cv.MatType.CV_64FC1), 0.0));
  }

  /// Returns a homography that maps an image from the `from` points to the `to`
  /// points. `addTo` may be specified to add the resulting homography onto an
  /// existing one
  static Future<Homography> getHomographyFromPoints(
      Iterable<Point> from, Iterable<Point> to,
      {Homography? addTo}) async {
    final srcPts =
        cv.Mat.from2DList(from.map((p) => [p.x, p.y]), cv.MatType.CV_64FC1);
    final dstPts =
        cv.Mat.from2DList(to.map((p) => [p.x, p.y]), cv.MatType.CV_64FC1);

    final (homography, _) = await cv.findHomographyAsync(srcPts, dstPts,
        method: cv.RANSAC, ransacReprojThreshold: 5.0);

    if (addTo == null) {
      return Homography.fromMatrix(homography);
    }

    return Homography.fromMatrix(await cv.gemmAsync(addTo.getMatrix(),
        homography, 1.0, cv.Mat.zeros(3, 3, cv.MatType.CV_64FC1), 0.0));
  }

  /// Applies a homography to an image and saves it to the destination
  static Future<void> applyHomographyAndSave(
      File initial, Homography homography, File destination) async {}

  /// Applies a homography to an image
  static Future<cv.Mat> applyHomography(
      File initial, Homography homography) async {
    return await applyHomographyMat(initial, homography.getMatrix());
  }

  /// Applies a homography to an image
  static Future<cv.Mat> applyHomographyMat(
      File initial, cv.Mat homography) async {
    final image = await cv.imreadAsync(initial.path);

    final aligned = await cv.warpPerspectiveAsync(
        image, homography, (image.shape[1], image.shape[0]));

    return aligned;
  }
}
