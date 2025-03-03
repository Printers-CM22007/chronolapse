import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';

import 'frame_data.dart';

/// An interface for interacting with timelapse frames on-disk
class TimelapseFrame {
  String? _uuid;
  final String _projectName;
  FrameData data;

  /// Returns the uuid of the frame. A frame will not have a uuid if it has
  /// not been saved to disk.
  String? uuid() => _uuid;

  String _getUuid() {
    if (_uuid == null) {
      throw Exception(
          "Uuid not set as frame hasn't been loaded from disc and hasn't been saved");
    }
    return _uuid!;
  }

  /// Loads an existing frame from disk
  static Future<TimelapseFrame> fromExisting(
      String projectName, String uuid) async {
    final file = _getFrameDataFile(projectName, uuid);

    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    final data = FrameData.fromJson(jsonData);

    return TimelapseFrame._(uuid, projectName, data);
  }

  TimelapseFrame._(String? uuid, String projectName, FrameData pData)
      : _uuid = uuid,
        _projectName = projectName,
        data = pData;

  /// Creates a new frame (unsaved on disk) with initial `FrameData`
  TimelapseFrame.createNew(String projectName)
      : _projectName = projectName,
        data = FrameData.initial(projectName);

  /// Creates a new frame (unsaved on disk) from specified `FrameData`
  TimelapseFrame.createNewWithData(String projectName, FrameData pData)
      : _projectName = projectName,
        data = pData;

  /// Returns a file handle for the actual image of the frame. Will throw an
  /// exception if this frame hasn't been saved to disk yet (and thus the image
  /// file does not exist).
  File getFramePng() {
    return _getFrameImageFile(_projectName, _getUuid());
  }

  /// Saves frame data and the frame (the `file` parameter) to disk
  Future<void> saveFrameFromPngFile(File file) async {
    _uuid ??= await TimelapseStore.getAndAppendFrameUuid(_projectName);

    await Future.wait([
      saveFrameDataOnly(),
      file.copy(_getFrameImageFile(_projectName, _getUuid()).path)
    ]);
  }

  /// Saves frame data and the frame (the `pngData` parameter) to disk
  Future<void> saveFrameFromPngBytes(Uint8List pngData) async {
    _uuid ??= await TimelapseStore.getAndAppendFrameUuid(_projectName);

    await Future.wait([
      saveFrameDataOnly(),
      _getFrameImageFile(_projectName, _getUuid()).writeAsBytes(pngData)
    ]);
  }

  /// Saves frame data to disk. This will only work if the frame itself has been
  /// saved to disk as frame data existing without a frame is not permitted!
  Future<void> saveFrameDataOnly() async {
    if (_uuid == null) {
      throw Exception(
          "Cannot save frame data only without a frame image being present as this would leave a .json with no image");
    }

    final jsonString = jsonEncode(data.toJson());
    final file = _getFrameDataFile(_projectName, _getUuid());
    await file.writeAsString(jsonString);
  }

  /// Updates the `FrameData` with data from disk
  Future<void> updateDataFromDisk() async {
    final file = _getFrameDataFile(_projectName, _getUuid());

    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);
    data = FrameData.fromJson(jsonData);
  }

  /// Deletes the frame
  Future<void> deleteFrame() async {
    await TimelapseStore.deleteFrameUuid(_projectName, _getUuid());
    _uuid = null;
    await _getFrameImageFile(_projectName, _getUuid()).delete();
  }

  /// Returns the frame data file
  static File _getFrameDataFile(String projectName, String uuid) {
    return File("${TimelapseStore.getProjectDir(projectName).path}/$uuid.json");
  }

  /// Returns the frame file
  static File _getFrameImageFile(String projectName, String uuid) {
    return File("${TimelapseStore.getProjectDir(projectName).path}/$uuid.png");
  }
}
