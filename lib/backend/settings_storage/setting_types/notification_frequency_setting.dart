part of 'project_setting.dart';

class NotificationFrequencySetting
    extends PersistentSetting<NotificationFrequency?> {
  const NotificationFrequencySetting(super._key, super._defaultValue);

  @override
  NotificationFrequency? getValue(String projectPrefix) {
    final val = SettingsStore.sp().getString(projectPrefix + super._key);
    return val != null
        ? NotificationFrequencyExt.getOptionFromString(val)
        : super._defaultVal;
  }

  @override
  Future<void> setValue(
      String projectPrefix, NotificationFrequency? value) async {
    if (value == null) {
      // NotificationSystem.cancelNotification(projectPrefix.hashCode);
    } else {
      // NotificationSystem.createNotification(projectPrefix.hashCode, value);
    }
    await SettingsStore.sp().setString(
        projectPrefix + super._key, value?.stringRepresentation() ?? "");
  }

  @override
  Widget getWidget(String projectPrefix) {
    return NotificationFrequencyWidget(this, projectPrefix);
  }
}

class NotificationFrequencyWidget extends StatefulWidget {
  final NotificationFrequencySetting _setting;
  final String _projectPrefix;

  const NotificationFrequencyWidget(this._setting, this._projectPrefix,
      {super.key});

  @override
  State<NotificationFrequencyWidget> createState() =>
      _NotificationFrequencySettingWidgetState();
}

class _NotificationFrequencySettingWidgetState
    extends State<NotificationFrequencyWidget> {
  NotificationFrequency? _value;

  @override
  void initState() {
    _value = widget._setting.getValue(widget._projectPrefix);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const String neverEntry = "Never";
    return ListTile(
        title: const Text('Notification Frequency'),
        trailing: DropdownButton<String>(
          value: _value?.stringRepresentation() ?? neverEntry,
          onChanged: (String? newValue) async {
            if (newValue == null) {
              return;
            }
            final NotificationFrequency? freqOpt;
            if (newValue == neverEntry) {
              freqOpt = null;
            } else {
              freqOpt = NotificationFrequencyExt.getOptionFromString(newValue);
            }
            await widget._setting.setValue(widget._projectPrefix, freqOpt);
            setState(() {
              _value = freqOpt;
            });
          },
          items: (["Never"] +
                  NotificationFrequency.values.map<String>((vf) {
                    return vf.stringRepresentation();
                  }).toList())
              .map<DropdownMenuItem<String>>((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ));
  }
}
