import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:opencv_dart/opencv.dart' as cv;


class ImageTransformer {
  static Future<Homography> transformImage(
      ProjectTimelapseData projectData, TimelapseFrame frame) async {
    cv.Mat img = await cv.imreadAsync(frame.getFramePng().path);

    throw UnimplementedError();
  }
}
