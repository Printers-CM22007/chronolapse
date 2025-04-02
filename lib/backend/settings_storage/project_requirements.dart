import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';
import 'package:flutter/material.dart';

/// Either the name of a project or global
class ProjectName {
  final String? _projectName;

  const ProjectName(String? project) : _projectName = project;

  const ProjectName.global() : _projectName = null;

  // Ignored because it is a getter
  String? name() => _projectName; // coverage:ignore-line

  /// Prefix in SharedPreferences before the setting key
  String settingPrefix() =>
      _projectName == null ? "global/" : "project/$_projectName/";
}

/// A setting with a project selected (or none if global)
class PersistentSettingWithProject<T> {
  final ProjectName _project;
  final PersistentSetting<T> _setting;

  const PersistentSettingWithProject(this._project, this._setting);

  // Ignored because it is a getter
  ProjectName project() => _project; // coverage:ignore-line

  // Ignored because it is a getter
  PersistentSetting<T> setting() => _setting; // coverage:ignore-line

  /// Gets the value of the setting
  // Ignored because it is trivial - the underlying .getValue will be tested
  T getValue() => _setting.getValue(_project); // coverage:ignore-line

  /// Sets the value of the setting
  Future<void> setValue(T value) async {
    await _setting.setValue(_project, value);
  }

  /// Gets the widget for the settings page for this setting
  // Ignored because it is a utility wrapper, .getWidget implementation will have to be covered
  // coverage:ignore-start
  Widget getWidget() {
    return _setting.getWidget(_project);
  }
  // coverage:ignore-end

  /// Restricts usage to only being able to get the widget
  WidgetSettingWithProject<T> asWidgetOnly() {
    return WidgetSettingWithProject(_project, _setting);
  }
}

/// A project-less setting
class Global<T> extends PersistentSettingWithProject<T> {
  const Global(PersistentSetting<T> setting)
      // LCOV incorrectly believes the next line is separate from the previous
      : super(const ProjectName.global(), setting); // coverage:ignore-line

  /// Restricts usage to only being able to get the widget
  @override
  WidgetSettingGlobal<T> asWidgetOnly() {
    return WidgetSettingGlobal(_setting);
  }
}

/// A setting with a project selected (or none if global) where only getting
/// the settings page widget is available
class WidgetSettingWithProject<T> {
  final ProjectName _project;
  final SettingWidget<T> _setting;

  const WidgetSettingWithProject(this._project, this._setting);

  /// Gets the widget for the settings page for this setting
  Widget getWidget() {
    return _setting.getWidget(_project);
  }
}

/// A project-less setting where where only getting
/// the settings page widget is available
class WidgetSettingGlobal<T> extends WidgetSettingWithProject<T> {
  const WidgetSettingGlobal(SettingWidget<T> setting)
      : super(const ProjectName.global(), setting);
}

/// A setting that requires a project to be specified
class RequiresProject<T> {
  final PersistentSetting<T> _setting;

  const RequiresProject(this._setting);

  /// Ties this setting to a specified project
  PersistentSettingWithProject<T> withProject(ProjectName projectName) {
    return PersistentSettingWithProject(projectName, _setting);
  }

  // /// Ties this setting to the `currentProject`. A runtime error will be thrown
  // /// if `currentProject` is null
  // PersistentSettingWithProject<T> withCurrentProject() {
  //   return PersistentSettingWithProject(currentProject!, _setting);
  // }

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
  WidgetSettingWithProject<T> withProject(ProjectName projectName) {
    return WidgetSettingWithProject(projectName, _setting);
  }

  // /// Ties this widget to the `currentProject`. A runtime error will be thrown
  // /// if `currentProject` is null
  // WidgetSettingWithProject<T> withCurrentProject() {
  //   return WidgetSettingWithProject(currentProject!, _setting);
  // }
}
