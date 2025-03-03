
import 'package:json_annotation/json_annotation.dart';

import 'frame_metadata.dart';

part 'frame_data.g.dart';

@JsonSerializable()

/// Holds data about a timelapse. !! Only modify the data you added - e.g. don't
/// modify `TimelapseMetaData` from outside `timelapse_storage` code !!
class FrameData {
  FrameMetaData metaData;

  FrameData({required this.metaData});

  factory FrameData.initial(String projectName) {
    return FrameData(metaData: FrameMetaData.initial(projectName));
  }

  factory FrameData.fromJson(Map<String, dynamic> json) =>
      _$FrameDataFromJson(json);
  Map<String, dynamic> toJson() => _$FrameDataToJson(this);
}
