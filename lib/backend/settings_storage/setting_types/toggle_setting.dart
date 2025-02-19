part of 'project_setting.dart';

final WidgetStateProperty<Icon?> _thumbIcon =
    WidgetStateProperty.resolveWith<Icon?>((states) {
  if (states.contains(WidgetState.selected)) {
    return const Icon(Icons.check);
  }
  return const Icon(Icons.close);
});

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
    return SwitchListTile(
      title: const Text('Upload Over Other Networks'),
      thumbIcon: _thumbIcon,
      subtitle:
          const Text('Images will be uploaded through other WiFi networks'),
      value: false,
      onChanged: (bool value) {},
    );
  }
}
