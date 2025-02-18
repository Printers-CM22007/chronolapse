import 'package:chronolapse/backend/settings_storage/project_setting.dart';
import 'package:flutter/material.dart';


class ProjectSetting<T> {
  final String _project;
  final PersistentSettings<T> _setting;

  const ProjectSetting(this._project, this._setting);

  String _projectPrefix() => "$_project/";

  @override
  Widget getWidget() {
    return _setting.getWidget(_projectPrefix());
  }
}

class GlobalSetting<T> extends ProjectSetting<T> {
  const GlobalSetting(setting) : super("", setting);
}

class WidgetRequiresProject<T> {
  final PersistentSetting<T> _setting;

  const WidgetRequiresProject(this._setting);

  WidgetProjectSetting<T> withProject(String project) {
    return WidgetProjectSetting(project, _setting);
  }
}

class RequiresProject<T> extends WidgetRequiresProject<T> {
  RequiresProject(super.project, super.setting);

  @override
  T getValue() {
    return _setting.getValue(_projectPrefix());
  }

  @override
  Future<void> setValue(T value) async {
    await _setting.setValue(_projectPrefix(), value);
  }
}