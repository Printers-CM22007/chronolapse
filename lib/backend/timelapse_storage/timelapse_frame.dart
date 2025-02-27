import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';

class TimelapseFrame {
  String? _uuid;
  late String _projectName;

  String uuid() {
    if (_uuid == null) {
      throw Exception(
          "Uuid not set as frame hasn't been loaded from disc and hasn't been saved");
    }
    return _uuid!;
  }

  TimelapseFrame.fromExisting(String projectName, String uuid) {
    _uuid = uuid;
    _projectName = projectName;
    throw UnimplementedError();
  }

  // TimelapseFrame(String project) {
  //   throw UnimplementedError();
  // }

  Future<void> saveFrame() async {
    _uuid ??= await TimelapseStore.getAndAppendFrameUuid(_projectName);
    throw UnimplementedError();
  }

  Future<void> deleteFrame() async {
    await TimelapseStore.deleteFrameUuid(_projectName, uuid());
    _uuid = null;
    throw UnimplementedError();
  }
}
