import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';

const String timelapseDirectory = "timelapses";

const String timelapseProjectListKey = "timelapse_store/project_list";

/// An interface for interacting with timelapse files on-disk
class TimelapseStore {
  static TimelapseStore? _instance;

  static TimelapseStore instance() {
    if (_instance == null) {
      throw Exception(
          "TimelapseStore.initialise() has not been called (must be awaited)");
    }
    return _instance!;
  }

  final Directory _baseDir;
  final Directory _timelapseDir;
  TimelapseStore._(this._baseDir, this._timelapseDir);

  /// `SettingsStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<void> initialise() async {
    // Initialise project list setting value
    if (!SettingsStore.sp().containsKey(timelapseProjectListKey)) {
      SettingsStore.sp().setStringList(timelapseProjectListKey, []);
    }

    Directory baseDir = await getApplicationDocumentsDirectory();
    final timelapseDir = baseDir.uri;

    _instance = TimelapseStore._(baseDir, baseDir);
  }

  static List<String> getProjectList() {
    instance();
    return SettingsStore.sp().getStringList(timelapseProjectListKey) ?? [];
  }
}