part of 'project_setting.dart';

class ToggleSetting extends PersistentSetting<bool> {
  const ToggleSetting(super._key, super._defaultVal);

  @override
  bool getValue(String projectPrefix) {
    return SharedStorage.sp().getBool(projectPrefix + super._key) ??
        super._defaultVal;
  }

  @override
  Future<void> setValue(String projectPrefix, bool value) async {
    await SharedStorage.sp().setBool(projectPrefix + super._key, value);
  }

  @override
  Widget getWidget(String projectPrefix) {
    // TODO: implement getWidget
    throw UnimplementedError();
  }
}

class DividerNoSetting extends SettingWidget<None> {
  const DividerNoSetting() : super("", const None());

  @override
  Widget getWidget(String projectPrefix) {
    return const Divider();
  }
}
