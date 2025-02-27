import 'dart:convert';

import 'package:chronolapse/backend/timelapse_storage/timelapse_metadata.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timelapse_data.g.dart';

class ProjectTimelapseData {
  final TimelapseData data;
  final String _projectName;

  const ProjectTimelapseData(this.data, this._projectName);

  Future<void> saveChanges() async {
    final jsonString = jsonEncode(data.toJson());
    final file = TimelapseStore.getProjectDataFile(_projectName);
    await file.writeAsString(jsonString);
  }
}

@JsonSerializable()

/// Holds data about a timelapse. !! Only modify the data you added - e.g. don't
/// modify `TimelapseMetaData` from outside `timelapse_storage` code !!
class TimelapseData {
  TimelapseMetaData metaData;

  TimelapseData({required this.metaData});

  factory TimelapseData.initial(String projectName) {
    return TimelapseData(metaData: TimelapseMetaData.initial(projectName));
  }

  factory TimelapseData.fromJson(Map<String, dynamic> json) =>
      _$TimelapseDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimelapseDataToJson(this);
}
