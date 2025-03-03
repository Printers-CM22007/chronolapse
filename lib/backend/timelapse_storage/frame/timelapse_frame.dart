import 'dart:convert';
import 'dart:io';

import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';

import 'frame_data.dart';

class TimelapseFrame {
  String? _uuid;
  final String _projectName;
  FrameData data;

  String? uuid() => _uuid;

  String _getUuid() {
    if (_uuid == null) {
      throw Exception(
          "Uuid not set as frame hasn't been loaded from disc and hasn't been saved");
    }
    return _uuid!;
  }

  static Future<TimelapseFrame> fromExisting(
      String projectName, String uuid) async {
    final file = getFrameDataFile(projectName, uuid);

    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    final data = FrameData.fromJson(jsonData);

    return TimelapseFrame._(uuid, projectName, data);
  }

  TimelapseFrame._(String? uuid, String projectName, FrameData pData)
      : _uuid = uuid,
        _projectName = projectName,
        data = pData;

  TimelapseFrame.createNew(String projectName)
      : _projectName = projectName,
        data = FrameData.initial(projectName);

  TimelapseFrame.createNewWithData(String projectName, FrameData pData)
      : _projectName = projectName,
        data = pData;

  Future<void> saveFrameFromFile(File file) async {
    _uuid ??= await TimelapseStore.getAndAppendFrameUuid(_projectName);

    await Future.wait([
      saveFrameDataOnly(),
      file.copy(getFrameImageFile(_projectName, _getUuid()).path)
    ]);
  }

  Future<void> saveFrameDataOnly() async {
    if (_uuid == null) {
      throw Exception(
          "Cannot save frame data only without a frame image being present as this would leave a .json with no image");
    }

    final jsonString = jsonEncode(data.toJson());
    final file = getFrameDataFile(_projectName, _getUuid());
    await file.writeAsString(jsonString);
  }

  Future<void> deleteFrame() async {
    await TimelapseStore.deleteFrameUuid(_projectName, _getUuid());
    _uuid = null;
    await getFrameImageFile(_projectName, _getUuid()).delete();
  }

  static File getFrameDataFile(String projectName, String uuid) {
    return File("${TimelapseStore.getProjectDir(projectName).path}/$uuid.json");
  }

  static File getFrameImageFile(String projectName, String uuid) {
    return File("${TimelapseStore.getProjectDir(projectName).path}/$uuid.png");
  }
}
