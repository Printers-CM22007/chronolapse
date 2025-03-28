part of 'project_setting.dart';

class LastModifiedNoWidget extends PersistentSetting<int> {
  const LastModifiedNoWidget(key) : super(key, 0);

  @override
  int getValue(ProjectName projectName) {
    return SettingsStore.sp().getInt(projectName.settingPrefix() + super._key) ?? super._defaultVal;
  }

  @override
  Future<void> setValue(
      ProjectName projectName, int value) async {
    await SettingsStore.sp().setInt(projectName.settingPrefix() + super._key, value);
  }

  @override
  Widget getWidget(ProjectName projectName) {
    throw Exception("Do not use LastModifiedNoWidget as a widget!");
  }
}
