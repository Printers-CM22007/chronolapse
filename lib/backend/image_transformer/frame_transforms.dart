import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opencv_dart/opencv.dart' as cv;

part 'frame_transforms.g.dart';

@JsonSerializable()
class Homography {
  /// ! Do not modify directly
  final List<List<double>> vals;

  /// ! For use from generated JSON code only!
  const Homography({required this.vals});

  /// Creates a Homography from a 3x3 matrix
  factory Homography.fromMatrix(cv.Mat matrix) {
    if (matrix.shape.length != 3 ||
        matrix.shape[0] != 3 ||
        matrix.shape[1] != 3 ||
        matrix.shape[2] != 1) {
      throw Exception("Tried to create Homography from non-3x3 matrix");
    }

    return Homography(
        vals: matrix
            .toList()
            .map((x) => (x.map((y) => y.toDouble())).toList())
            .toList());
  }

  /// Returns a Homography representing no transformation. Should only be used
  /// for the first frame
  Homography.identity()
      : vals = [
          [1, 0, 0],
          [0, 1, 0],
          [0, 0, 1]
        ];

  /// Returns the homography as an OpenCV matrix
  cv.Mat getMatrix() {
    return cv.Mat.from2DList(vals, cv.MatType.CV_64FC1);
  }

  factory Homography.fromJson(Map<String, dynamic> json) =>
      _$HomographyFromJson(json);
  Map<String, dynamic> toJson() => _$HomographyToJson(this);
}

@JsonSerializable()
class FrameTransform {
  Homography transform;

  /// Represents whether this transform has been created manually and thus can
  /// be used for later automatic image alignment.
  final bool isKnown;

  /// ! For use from generated JSON code only
  FrameTransform({required this.transform, required this.isKnown});

  /// A transform that wasn't found automatically (i.e. user-verified)
  FrameTransform.userVerified(this.transform) : isKnown = true;

  /// A transform found with code
  FrameTransform.autoGenerated(this.transform) : isKnown = false;

  /// Returns the `FrameTransform` for the first frame which is treated as
  /// always being correctly aligned
  FrameTransform.baseFrame()
      : transform = Homography.identity(),
        isKnown = true;

  factory FrameTransform.fromJson(Map<String, dynamic> json) =>
      _$FrameTransformFromJson(json);
  Map<String, dynamic> toJson() => _$FrameTransformToJson(this);

  /// User verified transform from `fromPoints` to `toPoints`
  static Future<FrameTransform> fromFeaturePoints(
      List<FeaturePoint> featurePoints,
      List<FeaturePoint> referencePoints) async {
    final fromPoints =
        featurePoints.map((p) => Point(p.position.x, p.position.y));
    final toPoints =
        featurePoints.map((p) => Point(p.position.x, p.position.y));

    final homography =
        await ImageTransformer.getHomographyFromPoints(fromPoints, toPoints);

    return FrameTransform.userVerified(homography);
  }
}

@JsonSerializable()
class KnownFrameTransforms {
  /// List of image uuids with transforms that can be used for automatic
  /// alignment as they have been created by the user (or are the first frame)
  List<String> frames;

  KnownFrameTransforms({required this.frames});

  factory KnownFrameTransforms.initial() {
    return KnownFrameTransforms(frames: []);
  }

  factory KnownFrameTransforms.fromJson(Map<String, dynamic> json) =>
      _$KnownFrameTransformsFromJson(json);
  Map<String, dynamic> toJson() => _$KnownFrameTransformsToJson(this);
}
