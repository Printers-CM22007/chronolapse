// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timelapse_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelapseData _$TimelapseDataFromJson(Map<String, dynamic> json) =>
    TimelapseData(
      metaData:
          TimelapseMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimelapseDataToJson(TimelapseData instance) =>
    <String, dynamic>{
      'metaData': instance.metaData,
    };
