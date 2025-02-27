// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timelapse_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelapseMetaData _$TimelapseMetaDataFromJson(Map<String, dynamic> json) =>
    TimelapseMetaData(
      projectName: json['projectName'] as String,
      frames:
          (json['frames'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TimelapseMetaDataToJson(TimelapseMetaData instance) =>
    <String, dynamic>{
      'projectName': instance.projectName,
      'frames': instance.frames,
    };
