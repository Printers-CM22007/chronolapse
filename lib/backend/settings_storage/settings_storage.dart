import 'package:shared_preferences/shared_preferences.dart';

/// An interface to `SharedPreferences` - persistent storage of settings
class SharedStorage {
  static SharedStorage? _instance;

  final SharedPreferences _sp;
  SharedStorage._(this._sp);

  static Future<void> initialise() async {
    _instance = SharedStorage._(await SharedPreferences.getInstance());
  }

  /// Returns a reference to the singleton. `SharedStorage.initialise()` must have
  /// been called (and awaited) before this can be used
  static SharedPreferences sp() {
    if (_instance == null) {
      throw Exception(
          "SharedStorage.initialise() has not been called (must be awaited)");
    }
    return _instance!._sp;
  }

  /// Deletes all settings including project settings!
  /// `SharedStorage.initialise()` must have been called (and awaited) before
  /// this can be used
  static Future<bool> deleteAllSettings() {
    return _instance!._sp.clear();
  }

  /// `SharedStorage.initialise()` must have been called (and awaited) before
  /// this can be used
  static Future<void> deleteAllGlobalSettings() async {
    final sp = _instance!._sp;
    for (final key in sp.getKeys()) {
      if (!key.contains('/')) {
        await sp.remove(key);
      }
    }
  }

  /// Deletes all settings for a specified project
  /// `SharedStorage.initialise()` must have been called (and awaited) before
  /// this can be used
  static Future<void> deleteAllProjectSettings(String project) async {
    final sp = _instance!._sp;
    for (final key in sp.getKeys()) {
      if (!key.startsWith("$project/")) {
        await sp.remove(key);
      }
    }
  }
}
