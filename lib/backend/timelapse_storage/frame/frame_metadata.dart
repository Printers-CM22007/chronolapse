import 'package:json_annotation/json_annotation.dart';

part 'frame_metadata.g.dart';

/// Data used by TimelapseFrame code
@JsonSerializable()
class FrameMetaData {
  const FrameMetaData();

  factory FrameMetaData.initial(String projectName) {
    return const FrameMetaData();
  }

  factory FrameMetaData.fromJson(Map<String, dynamic> json) =>
      _$FrameMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$FrameMetaDataToJson(this);
}
