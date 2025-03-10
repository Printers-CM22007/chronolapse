import 'dart:math';

import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:opencv_dart/opencv.dart' as cv;

class ImageTransformer {
  static Future<Homography?> findHomography(
      ProjectTimelapseData projectData, TimelapseFrame frame) async {
    if (projectData.data.knownFrameTransforms.frames.isEmpty) {
      throw Exception("Cannot transform image without any known transforms");
    }

    // TODO: Apply better heuristics to this
    final referenceFrameUuid = projectData.data.knownFrameTransforms.frames[0];
    final referenceFrame = await TimelapseFrame.fromExisting(
        projectData.projectName(), referenceFrameUuid);
    final referenceImg = await cv.imreadAsync(
        referenceFrame
            .getFramePng()
            .path);
    final referenceGray =
        await cv.cvtColorAsync(referenceImg, cv.COLOR_BGR2GRAY);

    if (referenceFrame.data.frameTransform == null || !referenceFrame.data.frameTransform!.isKnown) {
      throw Exception("Reference frame '${referenceFrame.uuid()}' marked as "
          "having known transform in project '${projectData.projectName()}' "
          "however it is not present in the frame data");
    }
    final referenceHomography =
      referenceFrame.data.frameTransform!.transform.getMatrix();

    final img = await cv.imreadAsync(frame.getFramePng().path);
    final imgGray = await cv.cvtColorAsync(img, cv.COLOR_BGR2GRAY);

    // Have to provide mask including all pixels as mask argument is
    // non-nullable (WHY?!)
    final mask =
        cv.Mat.ones(img.rows, img.cols, cv.MatType.CV_8UC1).multiply(255);

    final orb = cv.ORB.create();
    final (kpRef, dscRef) =
        await orb.detectAndComputeAsync(referenceGray, mask);
    final (kpImg, dscImg) = await orb.detectAndComputeAsync(imgGray, mask);

    final bf = cv.BFMatcher.create(type: cv.NORM_HAMMING, crossCheck: true);
    final matches = (await bf.matchAsync(dscRef, dscImg)).toList();
    matches.sort((a, b) => a.distance.compareTo(b.distance));

    final numGoodMatches = max<int>((matches.length / 5).toInt(), 12);
    final goodMatches = matches.sublist(0, numGoodMatches);

    // TODO: Need to verify this
    final srcPts = cv.Mat.from2DList(
            goodMatches.map((e) => [kpRef[e.queryIdx].x, kpRef[e.queryIdx].y]),
            cv.MatType.CV_64FC1);
    final dstPts = cv.Mat.from2DList(
            goodMatches.map((e) => [kpImg[e.trainIdx].x, kpImg[e.trainIdx].y]),
            cv.MatType.CV_64FC1);

    final (homography, _) = await cv.findHomographyAsync(dstPts, srcPts, method: cv.RANSAC, ransacReprojThreshold: 5.0);

    // TODO: Ensure homography is sensible

    return Homography.fromMatrix(cv.gemm(referenceHomography, homography, 1.0, cv.Mat.zeros(3, 3, cv.MatType.CV_64FC1), 0.0));
  }
}
