import 'package:flutter/material.dart';

abstract class APersistentSetting<T> {
  final String _key;
  final T _defaultVal;

  const APersistentSetting(this._key, this._defaultVal);
}

abstract class WidgetOnlySetting<T> extends APersistentSetting<T> {
  const WidgetOnlySetting(super.key, super.defaultVal);

  Widget getWidget(String projectPrefix);
}

abstract class PersistentSettings<T> extends WidgetOnlySetting<T> {
  const PersistentSettings(super.key, super.defaultVal);

  T getValue(String projectPrefix);

  Future<void> setValue(String projectPrefix, T value);
}

