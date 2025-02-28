import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:flutter/material.dart';

import '../../../util/util.dart';

part './toggle_setting.dart';
part './divider_no_setting.dart';
part './title_no_setting.dart';

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
  Widget getWidget(String projectPrefix);
}

/// A persistent setting
abstract class PersistentSetting<T> extends SettingWidget<T> {
  const PersistentSetting(super._key, super._defaultVal);

  /// Returns the value of the setting it is tied to
  T getValue(String projectPrefix);

  /// Sets the value of the setting it is tied to
  Future<void> setValue(String projectPrefix, T value);
}
