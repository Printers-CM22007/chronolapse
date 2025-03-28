import 'dart:convert';

import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/settings_options.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_metadata.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timelapse_data.g.dart';

@JsonSerializable()

/// Holds data about a timelapse. !! Only modify the data you added - e.g. don't
/// modify `TimelapseMetaData` from outside `timelapse_storage` code !!
class TimelapseData {
  TimelapseMetaData metaData;
  KnownFrameTransforms knownFrameTransforms;

  TimelapseData({required this.metaData, required this.knownFrameTransforms});

  factory TimelapseData.initial(String projectName) {
    return TimelapseData(
      metaData: TimelapseMetaData.initial(projectName),
      knownFrameTransforms: KnownFrameTransforms(frames: []),
    );
  }

  factory TimelapseData.fromJson(Map<String, dynamic> json) =>
      _$TimelapseDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimelapseDataToJson(this);
}

/// A wrapper around `TimelapseData` allowing for saving and reloading, as well
/// as having a project specified
class ProjectTimelapseData {
  TimelapseData data;
  final String _projectName;

  String projectName() => _projectName;

  ProjectTimelapseData(this.data, this._projectName);

  /// Saves changes made to the `data` attribute to disk
  Future<void> saveChanges() async {
    final jsonString = jsonEncode(data.toJson());
    final file = TimelapseStore.getProjectDataFile(_projectName);
    await file.writeAsString(jsonString);
    await lastModifiedProject.withProject(ProjectName(_projectName)).setValue(DateTime.now().millisecondsSinceEpoch);
  }

  /// Loads changes from disk
  Future<void> reloadFromDisk() async {
    final file = TimelapseStore.getProjectDataFile(_projectName);

    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    data = TimelapseData.fromJson(jsonData);
  }

  // TimelapseFrame createNewFrame() => TimelapseFrame.createNew(_projectName);
  // TimelapseFrame createNewFrameWithData(FrameData data) =>
  //     TimelapseFrame.createNewWithData(_projectName, data);
}
