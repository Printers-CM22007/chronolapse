import 'package:json_annotation/json_annotation.dart';
import 'package:opencv_dart/opencv.dart' as cv;

part 'frame_transforms.g.dart';

@JsonSerializable()
class Homography {
  /// ! Do not modify directly
  final List<List<double>> vals;

  /// ! For use from generated JSON code only!
  const Homography({required this.vals});

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

  cv.Mat getMatrix() {
    return cv.Mat.from2DList(vals, cv.MatType.CV_64FC1);
  }

  factory Homography.fromJson(Map<String, dynamic> json) =>
      _$HomographyFromJson(json);
  Map<String, dynamic> toJson() => _$HomographyToJson(this);
}

@JsonSerializable()
class FrameTransform {
  final Homography transform;

  /// Represents whether this transform has been verified by the user
  final bool isKnown;

  const FrameTransform({required this.transform, required this.isKnown});

  factory FrameTransform.fromJson(Map<String, dynamic> json) =>
      _$FrameTransformFromJson(json);
  Map<String, dynamic> toJson() => _$FrameTransformToJson(this);
}

@JsonSerializable()
class KnownFrameTransforms {
  /// List of image uuids with known transforms
  List<String> frames;

  KnownFrameTransforms({required this.frames});

  factory KnownFrameTransforms.initial() {
    return KnownFrameTransforms(frames: []);
  }

  factory KnownFrameTransforms.fromJson(Map<String, dynamic> json) =>
      _$KnownFrameTransformsFromJson(json);
  Map<String, dynamic> toJson() => _$KnownFrameTransformsToJson(this);
}
