import 'dart:math';

import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:opencv_dart/opencv.dart' as cv;

class ImageTransformer {
  static Future<Homography?> transformImage(
      ProjectTimelapseData projectData, TimelapseFrame frame) async {
    if (projectData.data.knownFrameTransforms.frames.isEmpty) {
      throw Exception("Cannot transform image without any known transforms");
    }

    // TODO: Apply better heuristics to this
    final referenceFrameUuid = projectData.data.knownFrameTransforms.frames[0];
    final referenceFrame = await cv.imreadAsync(
        (await TimelapseFrame.fromExisting(
                projectData.projectName(), referenceFrameUuid))
            .getFramePng()
            .path);
    final referenceGray = await cv.cvtColorAsync(referenceFrame, cv.COLOR_BGR2GRAY);

    final img = await cv.imreadAsync(frame.getFramePng().path);
    final imgGray = await cv.cvtColorAsync(img, cv.COLOR_BGR2GRAY);

    // Have to provide mask including all pixels as mask argument is
    // non-nullable (WHY?!)
    final mask = cv.Mat.ones(img.rows, img.cols, cv.MatType.CV_8UC1).multiply(255);

    final orb = cv.ORB.create();
    final (kpRef, dscRef) = await orb.detectAndComputeAsync(referenceGray, mask);
    final (kpImg, dscImg) = await orb.detectAndComputeAsync(imgGray, mask);

    final bf = cv.BFMatcher.create();
    final matches = (await bf.matchAsync(dscRef, dscImg)).toList();
    matches.sort((a, b) => a.distance.compareTo(b.distance));

    final numGoodMatches = max<int>((matches.length / 5).toInt(), 12);
    final goodMatches = matches.sublist(0, numGoodMatches);

    // TODO: Need to verify this
    final scr_pts = cv.Mat.from2DList(goodMatches.map((e) => [kpRef[e.queryIdx].x, kpRef[e.queryIdx].y]), cv.MatType.CV_32FC1).reshapeTo(0, [-1, 1, 2]);
    final dst_pts = cv.Mat.from2DList(goodMatches.map((e) => [kpImg[e.queryIdx].x, kpImg[e.queryIdx].y]), cv.MatType.CV_32FC1).reshapeTo(0, [-1, 1, 2]);

    final (homography, _) = await cv.findHomographyAsync(dst_pts, scr_pts);

    // TODO: Ensure homography is sensible

    return Homography.fromMatrix(homography);
  }
}
