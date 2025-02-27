import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_metadata.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';

const String timelapseDirName = "timelapses";

const String timelapseProjectListKey = "timelapse_store/project_list";

RegExp projectNameRegex = RegExp(r'^[a-zA-Z0-9 ]*$');

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
    final baseDir = await getApplicationDocumentsDirectory();
    final timelapseDir = Directory("${baseDir.path}/$timelapseDirName");

    if (!await timelapseDir.exists()) {
      await timelapseDir.create();
    }

    final contents = timelapseDir.list();
    final projects = <String>[];
    await for (final f in contents) {
      if (await Directory(f.path).exists()) {
        projects.add(f.path.split("/").last);
      }
    }

    SettingsStore.sp().setStringList(timelapseProjectListKey, projects);

    _instance = TimelapseStore._(baseDir, timelapseDir);
  }

  static List<String> getProjectList() {
    instance();
    return SettingsStore.sp().getStringList(timelapseProjectListKey) ?? [];
  }

  static Directory getProjectDir(String projectName) {
    return Directory("${instance()._timelapseDir.path}/$projectName");
  }

  static File getProjectDataFile(String projectName) {
    return File("${TimelapseStore.getProjectDir(projectName).path}/timelapse_data.json");
  }

  static Future<ProjectTimelapseData?> createProject(String projectName) async {
    if (getProjectList().contains(projectName) || !projectNameRegex.hasMatch(projectName)) {
      return null;
    }

    final t = instance();

    final projectDir = await getProjectDir(projectName).create();

    final data = ProjectTimelapseData(TimelapseData.initial(projectName), projectName);

    data.saveChanges();

    return data;
  }

  static Future<ProjectTimelapseData> getProjectData(String projectName) async {
    final file = getProjectDataFile(projectName);

    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    return ProjectTimelapseData(TimelapseData.fromJson(jsonData), projectName);
  }
}