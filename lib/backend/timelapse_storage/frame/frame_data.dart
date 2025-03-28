import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:json_annotation/json_annotation.dart';

import 'frame_metadata.dart';

part 'frame_data.g.dart';

@JsonSerializable()

/// Holds data about a frame. !! Only modify the data you added - e.g. don't
/// modify `FrameMetaData` from outside `timelapse_storage/frame` code !!
class FrameData {
  FrameMetaData metaData;

  FrameTransform frameTransform;

  FrameData({required this.metaData, required this.frameTransform});

  factory FrameData.initial(String projectName, FrameTransform frameTransformation) {
    return FrameData(
        metaData: FrameMetaData.initial(projectName), frameTransform: frameTransformation);
  }

  factory FrameData.fromJson(Map<String, dynamic> json) =>
      _$FrameDataFromJson(json);
  Map<String, dynamic> toJson() => _$FrameDataToJson(this);
}
