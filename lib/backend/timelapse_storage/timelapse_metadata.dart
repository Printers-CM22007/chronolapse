import 'package:json_annotation/json_annotation.dart';

part 'timelapse_metadata.g.dart';

/// Data used by TimelapseStore code
@JsonSerializable()
class TimelapseMetaData {
  final String projectName;
  final List<String> frames;

  TimelapseMetaData({required this.projectName, required this.frames});

  factory TimelapseMetaData.initial(String projectName) {
    return TimelapseMetaData(projectName: projectName, frames: []);
  }

  factory TimelapseMetaData.fromJson(Map<String, dynamic> json) =>
      _$TimelapseMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimelapseMetaDataToJson(this);
}
