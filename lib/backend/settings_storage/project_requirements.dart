import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';
import 'package:chronolapse/main.dart';
import 'package:flutter/material.dart';

/// A setting with a project selected (or none if global)
class PersistentSettingWithProject<T> {
  final String _project;
  final PersistentSetting<T> _setting;

  const PersistentSettingWithProject(this._project, this._setting);

  String _projectPrefix() =>
      _project.isEmpty ? "global/" : "project/$_project/";

  String project() => _project;
  PersistentSetting<T> setting() => _setting;

  /// Gets the value of the setting
  T getValue() {
    return _setting.getValue(_projectPrefix());
  }

  /// Sets the value of the setting
  Future<void> setValue(T value) async {
    await _setting.setValue(_projectPrefix(), value);
  }

  /// Gets the widget for the settings page for this setting
  Widget getWidget() {
    return _setting.getWidget(_projectPrefix());
  }

  /// Restricts usage to only being able to get the widget
  WidgetSettingWithProject<T> asWidgetOnly() {
    return WidgetSettingWithProject(_project, _setting);
  }
}

/// A project-less setting
class Global<T> extends PersistentSettingWithProject<T> {
  const Global(PersistentSetting<T> setting) : super("", setting);

  @override
  WidgetSettingGlobal<T> asWidgetOnly() {
    return WidgetSettingGlobal(_setting);
  }
}

/// A setting with a project selected (or none if global) where only getting
/// the settings page widget is available
class WidgetSettingWithProject<T> {
  final String _project;
  final SettingWidget<T> _setting;

  const WidgetSettingWithProject(this._project, this._setting);

  String _projectPrefix() =>
      _project.isEmpty ? "global/" : "project/$_project/";

  /// Gets the widget for the settings page for this setting
  Widget getWidget() {
    return _setting.getWidget(_projectPrefix());
  }
}

/// A project-less setting where where only getting
/// the settings page widget is available
class WidgetSettingGlobal<T> extends WidgetSettingWithProject<T> {
  const WidgetSettingGlobal(SettingWidget<T> setting) : super("", setting);
}

/// A setting that requires a project to be specified
class RequiresProject<T> {
  final PersistentSetting<T> _setting;

  const RequiresProject(this._setting);

  /// Ties this setting to a specified project
  PersistentSettingWithProject<T> withProject(String project) {
    return PersistentSettingWithProject(project, _setting);
  }

  /// Ties this setting to the `currentProject`. A runtime error will be thrown
  /// if `currentProject` is null
  PersistentSettingWithProject<T> withCurrentProject() {
    return PersistentSettingWithProject(currentProject!, _setting);
  }

  /// Restricts usage to only being able to get the widget
  WidgetSettingRequiresProject<T> asWidgetOnly() {
    return WidgetSettingRequiresProject(_setting);
  }
}

/// A setting that requires a project to be specified where only getting
// the settings page widget is available
class WidgetSettingRequiresProject<T> {
  final SettingWidget<T> _setting;

  const WidgetSettingRequiresProject(this._setting);

  /// Ties this widget to a specified project
  WidgetSettingWithProject<T> withProject(String project) {
    return WidgetSettingWithProject(project, _setting);
  }

  /// Ties this widget to the `currentProject`. A runtime error will be thrown
  /// if `currentProject` is null
  WidgetSettingWithProject<T> withCurrentProject() {
    return WidgetSettingWithProject(currentProject!, _setting);
  }
}
