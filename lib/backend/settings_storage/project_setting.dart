import 'package:chronolapse/backend/settings_storage/settings_storage.dart';
import 'package:flutter/material.dart';

import '../../util/util.dart';

part 'settings_storage_types.dart';

abstract class APersistentSetting<T> {
  final String _key;
  final T _defaultVal;

  const APersistentSetting(this._key, this._defaultVal);
}

abstract class SettingWidget<T> extends APersistentSetting<T> {
  const SettingWidget(super._key, super._defaultVal);

  Widget getWidget(String projectPrefix);
}

abstract class PersistentSetting<T> extends SettingWidget<T> {
  const PersistentSetting(super._key, super._defaultVal);

  T getValue(String projectPrefix);

  Future<void> setValue(String projectPrefix, T value);
}
