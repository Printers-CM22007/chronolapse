import 'package:shared_preferences/shared_preferences.dart';

/// An interface to `SharedPreferences` - persistent storage of settings
class SettingsStore {
  static SettingsStore? _instance;

  static SettingsStore instance() {
    if (_instance == null) {
      throw Exception(
          "SettingsStore.initialise() has not been called (must be awaited)");
    }
    return _instance!;
  }

  final SharedPreferences _sp;
  const SettingsStore._(this._sp);

  static Future<void> initialise() async {
    _instance = SettingsStore._(await SharedPreferences.getInstance());
  }

  /// Returns a reference to the singleton. `SettingsStore.initialise()` must have
  /// been called (and awaited) before this can be used. Do not use this without
  /// a wrapper!
  static SharedPreferences sp() {
    return instance()._sp;
  }

  /// Deletes all settings including project settings!
  /// `SettingsStore.initialise()` must have been called (and awaited) before
  /// this can be used
  static Future<bool> deleteAllSettings() {
    return instance()._sp.clear();
  }

  /// `SettingsStore.initialise()` must have been called (and awaited) before
  /// this can be used
  static Future<void> deleteAllGlobalSettings() async {
    final sp = instance()._sp;
    for (final key in sp.getKeys()) {
      if (key.startsWith('global/')) {
        await sp.remove(key);
      }
    }
  }

  /// Deletes all settings for a specified project
  /// `SettingsStore.initialise()` must have been called (and awaited) before
  /// this can be used
  static Future<void> deleteAllProjectSettings(String project) async {
    final sp = instance()._sp;
    for (final key in sp.getKeys()) {
      if (key.startsWith("project/$project/")) {
        await sp.remove(key);
      }
    }
  }
}
