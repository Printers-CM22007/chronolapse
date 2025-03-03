import 'package:json_annotation/json_annotation.dart';

part 'frame_metadata.g.dart';

@JsonSerializable()
class FrameMetaData {

  FrameMetaData();

  factory FrameMetaData.initial(String projectName) {
    return FrameMetaData();
  }

  factory FrameMetaData.fromJson(Map<String, dynamic> json) =>
      _$FrameMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$FrameMetaDataToJson(this);
}
