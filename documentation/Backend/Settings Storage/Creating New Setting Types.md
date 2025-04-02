[Back](Settings%20Storage.md)

## Creating New Setting Types
All setting types, such as the `ToggleSetting` above, are created in `backend/settings_storage/setting_types`. To create a new one, add a line to the top of `project_setting.dart` as such:
```dart
// project_setting.dart
part './new_setting.dart';
```

And this line at the top of your new file:
```dart
// new_setting.dart
part of 'project_setting.dart';
```
> This allows inheritance to work correctly

Then extend the `PersistentSetting` class, like in `toggle_setting.dart`:
```dart
class ToggleSetting extends PersistentSetting<bool> {  
  final String _title;  
  final String _subtitle;  
  const ToggleSetting(super._key, super._defaultVal, this._title, this._subtitle);  
  
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
    return ToggleSettingWidget(this, projectPrefix, _title, _subtitle);  
  }  
}
```

You should create the widget so that on change, it updates the storage value, like in `toggle_setting.dart`:
```dart
class ToggleSettingWidget extends StatefulWidget {  
  final ToggleSetting _setting;  
  final String _projectPrefix;  
  final String _title;  
  final String _subtitle;  
  
  const ToggleSettingWidget(this._setting, this._projectPrefix, this._title, this._subtitle, {super.key});  
  
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
      title: Text(widget._title),  
      thumbIcon: _thumbIcon,  
      subtitle:  
          Text(widget._subtitle),  
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
```

