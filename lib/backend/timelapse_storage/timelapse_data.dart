import 'dart:convert';

import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/settings_options.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_metadata.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timelapse_data.g.dart';

@JsonSerializable()

/// Holds data about a timelapse. !! Only modify the data you added - e.g. don't
/// modify `TimelapseMetaData` from outside `timelapse_storage` code !!
class TimelapseData {
  /// Data used by TimelapseStore code
  TimelapseMetaData metaData;

  /// List of frames with user-verified transforms
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

  // Not covered because it is a getter
  String projectName() => _projectName; // coverage:ignore-line

  ProjectTimelapseData(this.data, this._projectName);

  /// Saves changes made to the `data` attribute to disk
  Future<void> saveChanges() async {
    final jsonString = jsonEncode(data.toJson());
    final file = TimelapseStore.getProjectDataFile(_projectName);
    await file.writeAsString(jsonString);
    await lastModifiedProject
        .withProject(ProjectName(_projectName))
        .setValue(DateTime.now().millisecondsSinceEpoch);
  }

  /// Loads changes from disk
  Future<void> reloadFromDisk() async {
    final file = TimelapseStore.getProjectDataFile(_projectName);

    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    data = TimelapseData.fromJson(jsonData);
  }

  /// Delete the frame with the given index, removing it from the project
  /// data and on disk
  /// Important: saveChanges() must be called after this
  Future<void> deleteFrame(int index) async {
    // Delete frame
    final frame = await getFrameWithIndex(index);
    await frame.deleteFrame();

    // Remove from storage
    data.metaData.frames.removeAt(index);
  }

  /// Returns the `TimelapseFrame` with the given index
  Future<TimelapseFrame> getFrameWithIndex(int index) async {
    return await TimelapseFrame.fromExisting(
        projectName(), data.metaData.frames[index]);
  }

  // TimelapseFrame createNewFrame() => TimelapseFrame.createNew(_projectName);
  // TimelapseFrame createNewFrameWithData(FrameData data) =>
  //     TimelapseFrame.createNewWithData(_projectName, data);
}
