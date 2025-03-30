import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:flutter/material.dart';

import '../../../util/util.dart';
import '../../notification_service.dart';

part 'toggle_setting.dart';
part 'divider_no_setting.dart';
part 'title_no_setting.dart';
part 'notification_frequency_setting.dart';
part 'last_modified_no_widget.dart';
part 'multistep_setting.dart';

/// Abstract parent class for shared behaviour between `SettingWidget` and
/// `PersistentSetting` - do not use
abstract class APersistentSetting<T> {
  final String _key;
  final T _defaultVal;

  const APersistentSetting(this._key, this._defaultVal);
}

/// A widget that can be placed on the settings page to modify project/global
/// settings
abstract class SettingWidget<T> extends APersistentSetting<T> {
  const SettingWidget(super._key, super._defaultVal);

  /// Returns the widget tied to its relevant setting
  Widget getWidget(ProjectName projectName);
}

/// A persistent setting
abstract class PersistentSetting<T> extends SettingWidget<T> {
  const PersistentSetting(super._key, super._defaultVal);

  String key() => _key;

  /// Returns the value of the setting it is tied to
  T getValue(ProjectName projectName);

  /// Sets the value of the setting it is tied to
  Future<void> setValue(ProjectName projectName, T value);
}
