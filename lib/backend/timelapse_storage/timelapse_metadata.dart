import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'timelapse_metadata.g.dart';

@JsonSerializable()
class TimelapseMetaData {
  final String projectName;

  TimelapseMetaData({required this.projectName});

  factory TimelapseMetaData.fromJson(Map<String, dynamic> json) => _$TimelapseMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimelapseMetaDataToJson(this);
}