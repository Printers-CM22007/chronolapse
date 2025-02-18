import 'package:chronolapse/backend/settings_storage/settings_storage.dart';
import 'package:flutter/material.dart';






class ToggleSetting extends FullSettings<bool> {
  const ToggleSetting(super._key, super._defaultVal);

  @override
  bool getValue(String projectPrefix) {
    return SharedStorage.sp().getBool(projectPrefix + _key) ?? _defaultVal;
  }

  @override
  Future<void> setValue(String projectPrefix, bool value) async {
    await SharedStorage.sp().setBool(projectPrefix + _key, value);
  }

  @override
  Widget getWidget(String projectPrefix) {
    // TODO: implement getWidget
    throw UnimplementedError();
  }
}

class DividerNoSetting extends WidgetOnlySetting<void> {
  DividerNoSetting(super.key, super.defaultVal);
  
  @override
  Widget getWidget(String projectPrefix) {
    return const Divider();
  }
}
