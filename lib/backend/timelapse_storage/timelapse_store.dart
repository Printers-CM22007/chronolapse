import 'dart:convert';
import 'dart:io';

import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const String timelapseDirName = "timelapses";

const String timelapseProjectListKey = "timelapse_store/project_list";

RegExp projectNameRegex = RegExp(r'^[a-zA-Z0-9 ]*$');
const String projectNameRegexFailureExplanation =
    "Must be alphanumeric and spaces";

/// An interface for interacting with timelapse files on-disk
class TimelapseStore {
  static TimelapseStore? _instance;

  static TimelapseStore _getInstance() {
    if (_instance == null) {
      throw Exception(
          "TimelapseStore.initialise() has not been called (must be awaited)");
    }
    return _instance!;
  }

  final Directory _baseDir;
  final Directory _timelapseDir;
  TimelapseStore._(this._baseDir, this._timelapseDir);

  /// Initialised `TimelapseStore`. `SettingsStore.initialise()` must have been
  /// called (and awaited) before this can be used.
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

    await SettingsStore.sp().setStringList(timelapseProjectListKey, projects);

    _instance = TimelapseStore._(baseDir, timelapseDir);
  }

  /// Returns a list of all the projects.
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static List<String> getProjectList() {
    _getInstance();
    return SettingsStore.sp().getStringList(timelapseProjectListKey) ?? [];
  }

  /// Returns the directory for a given project.
  static Directory getProjectDir(String projectName) {
    return Directory("${_getInstance()._timelapseDir.path}/$projectName");
  }

  /// Returns the data file for a given project.
  static File getProjectDataFile(String projectName) {
    return File(
        "${TimelapseStore.getProjectDir(projectName).path}/timelapse_data.json");
  }

  /// Returns null if the projectName is valid. Returns an error if not.
  static String? checkProjectName(String projectName) {
    if (getProjectList().contains(projectName)) {
      return "Project name already in use";
    }

    if (projectName.trim().isEmpty) {
      return "Project name must not be empty";
    }

    if (!projectNameRegex.hasMatch(projectName)) {
      return projectNameRegexFailureExplanation;
    }

    return null;
  }

  /// Creates a new project. The name must be unique and alpha-numeric (with
  /// spaces) - the function will return null if an invalid project name is
  /// used.
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<ProjectTimelapseData?> createProject(String projectName) async {
    if (checkProjectName(projectName) != null) {
      return null;
    }

    await getProjectDir(projectName).create();

    final projects = getProjectList();
    projects.add(projectName);
    await SettingsStore.sp().setStringList(timelapseProjectListKey, projects);

    final data =
        ProjectTimelapseData(TimelapseData.initial(projectName), projectName);

    data.saveChanges();

    return data;
  }

  /// Returns a given project (`ProjectTimelapseData`).
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<ProjectTimelapseData> getProject(String projectName) async {
    final file = getProjectDataFile(projectName);

    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString);

    return ProjectTimelapseData(TimelapseData.fromJson(jsonData), projectName);
  }

  /// Deletes a given project and its settings.
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<void> deleteProject(String projectName) async {
    final projects = getProjectList();
    projects.remove(projectName);
    await SettingsStore.sp().setStringList(timelapseProjectListKey, projects);
    await SettingsStore.deleteAllProjectSettings(projectName);
    await getProjectDir(projectName).delete(recursive: true);
  }

  /// Deletes all projects and their settings!
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<void> deleteAllProjects() async {
    final projects = getProjectList();
    await SettingsStore.sp().setStringList(timelapseProjectListKey, []);

    await Future.wait(projects.map((p) {
      return Future.wait([
        getProjectDir(p).delete(recursive: true),
        SettingsStore.deleteAllProjectSettings(p)
      ]);
    }));
  }

  /// Returns a new unused uuid.
  static String _getNewUuid(ProjectTimelapseData data) {
    var uuid = const Uuid().v4();
    while (data.data.metaData.frames.contains(uuid)) {
      uuid = const Uuid().v4();
    }
    return uuid;
  }

  /// Creates a new uuid, appends it to the frames list, and returns it.
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<String> getAndAppendFrameUuid(String projectName) async {
    final data = await getProject(projectName);
    final uuid = _getNewUuid(data);

    data.data.metaData.frames.add(uuid);
    await data.saveChanges();

    return uuid;
  }

  /// Creates a new uuid, insets it into the frames list, and returns it.
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<String> getAndInsertFrameUuid(
      String projectName, int position) async {
    final data = await getProject(projectName);
    final uuid = _getNewUuid(data);

    data.data.metaData.frames.insert(position, uuid);
    await data.saveChanges();

    return uuid;
  }

  /// Deletes a given frame
  /// `TimelapseStore.initialise()` must have been called (and awaited) before
  /// this can be used.
  static Future<void> deleteFrameUuid(String projectName, String uuid) async {
    final data = await getProject(projectName);
    data.data.metaData.frames.remove(uuid);
    await data.saveChanges();
  }
}
