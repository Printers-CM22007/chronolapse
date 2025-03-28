part of 'project_setting.dart';

class ToggleSetting extends PersistentSetting<bool> {
  final String _title;
  final String _subtitle;
  const ToggleSetting(
      super._key, super._defaultVal, this._title, this._subtitle);

  @override
  bool getValue(ProjectName projectName) {
    return SettingsStore.sp()
            .getBool(projectName.settingPrefix() + super._key) ??
        super._defaultVal;
  }

  @override
  Future<void> setValue(ProjectName projectName, bool value) async {
    await SettingsStore.sp()
        .setBool(projectName.settingPrefix() + super._key, value);
  }

  @override
  Widget getWidget(ProjectName projectName) {
    return ToggleSettingWidget(this, projectName, _title, _subtitle);
  }
}

class ToggleSettingWidget extends StatefulWidget {
  final ToggleSetting _setting;
  final ProjectName _projectName;
  final String _title;
  final String _subtitle;

  const ToggleSettingWidget(
      this._setting, this._projectName, this._title, this._subtitle,
      {super.key});

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
    _value = widget._setting.getValue(widget._projectName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget._title),
      thumbIcon: _thumbIcon,
      subtitle: Text(widget._subtitle),
      value: _value,
      onChanged: (bool value) async {
        await widget._setting.setValue(widget._projectName, value);
        setState(() {
          _value = value;
        });
      },
    );
  }
}
