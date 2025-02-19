part of 'project_setting.dart';

class ToggleSettingWidget extends StatefulWidget {
  final ToggleSetting _setting;
  final String _projectPrefix;

  const ToggleSettingWidget(this._setting, this._projectPrefix, {super.key});

  @override
  State<ToggleSettingWidget> createState() => _ToggleSettingWidgetState();
}

class _ToggleSettingWidgetState extends State<ToggleSettingWidget> {
  bool _value = false;

  final WidgetStateProperty<Icon?> _thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>((states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.close);
  });

  @override
  void initState() {
    _value = widget._setting.getValue(widget._projectPrefix);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Upload Over Other Networks'),
      thumbIcon: _thumbIcon,
      subtitle:
          const Text('Images will be uploaded through other WiFi networks'),
      value: _value,
      onChanged: (bool value) async {
        await widget._setting.setValue(widget._projectPrefix, value);
        setState(() {
          _value = value;
        });
      },
    );
  }
}

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
    return ToggleSettingWidget(this, projectPrefix);
  }
}
