import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:json_annotation/json_annotation.dart';

import 'frame_metadata.dart';

part 'frame_data.g.dart';

@JsonSerializable()

/// Holds data about a frame. !! Only modify the data you added - e.g. don't
/// modify `FrameMetaData` from outside `timelapse_storage/frame` code !!
class FrameData {
  /// Data used by TimelapseFrame code
  FrameMetaData metaData;

  /// Feature points for image alignment
  List<FeaturePoint> featurePoints;

  /// Calculated image transformation for alignment
  FrameTransform frameTransform;

  FrameData(
      {required this.metaData,
      required this.frameTransform,
      required this.featurePoints});

  factory FrameData.initial(
      String projectName, FrameTransform frameTransformation) {
    return FrameData(
        metaData: FrameMetaData.initial(projectName),
        frameTransform: frameTransformation,
        featurePoints: []);
  }

  factory FrameData.fromJson(Map<String, dynamic> json) =>
      _$FrameDataFromJson(json);
  Map<String, dynamic> toJson() => _$FrameDataToJson(this);
}
