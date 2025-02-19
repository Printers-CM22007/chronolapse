import 'package:chronolapse/backend/settings_storage/project_setting.dart';
import 'package:chronolapse/main.dart';
import 'package:flutter/material.dart';

class PersistentSettingWithProject<T> {
  final String _project;
  final PersistentSetting<T> _setting;

  const PersistentSettingWithProject(this._project, this._setting);

  String _projectPrefix() => "$_project/";

  String project() => _project;
  PersistentSetting<T> setting() => _setting;

  T getValue() {
    return _setting.getValue(_projectPrefix());
  }

  Future<void> setValue(T value) async {
    await _setting.setValue(_projectPrefix(), value);
  }

  Widget getWidget() {
    return _setting.getWidget(_projectPrefix());
  }

  WidgetSettingWithProject<T> asWidgetOnly() {
    return WidgetSettingWithProject(_project, _setting);
  }
}

class Global<T> extends PersistentSettingWithProject<T> {
  const Global(PersistentSetting<T> setting) : super("", setting);

  @override
  WidgetSettingGlobal<T> asWidgetOnly() {
    return WidgetSettingGlobal(_setting);
  }
}

class WidgetSettingWithProject<T> {
  final String _project;
  final SettingWidget<T> _setting;

  const WidgetSettingWithProject(this._project, this._setting);

  String _projectPrefix() => "$_project/";

  Widget getWidget() {
    return _setting.getWidget(_projectPrefix());
  }
}

class WidgetSettingGlobal<T> extends WidgetSettingWithProject<T> {
  const WidgetSettingGlobal(SettingWidget<T> setting) : super("", setting);
}

class RequiresProject<T> {
  final PersistentSetting<T> _setting;

  const RequiresProject(this._setting);

  PersistentSettingWithProject<T> withProject(String project) {
    return PersistentSettingWithProject(project, _setting);
  }

  PersistentSettingWithProject<T> withCurrentProject() {
    return PersistentSettingWithProject(currentProject!, _setting);
  }

  WidgetSettingRequiresProject<T> asWidgetOnly() {
    return WidgetSettingRequiresProject(_setting);
  }
}

class WidgetSettingRequiresProject<T> {
  final SettingWidget<T> _setting;

  const WidgetSettingRequiresProject(this._setting);

  WidgetSettingWithProject<T> withCurrentProject() {
    return WidgetSettingWithProject(currentProject!, _setting);
  }

  WidgetSettingWithProject<T> withProject(String project) {
    return WidgetSettingWithProject(project, _setting);
  }
}
