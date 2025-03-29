part of 'project_setting.dart';

class NotificationFrequencySetting
    extends PersistentSetting<NotificationFrequency?> {
  const NotificationFrequencySetting(super._key, super._defaultValue);

  @override
  NotificationFrequency? getValue(ProjectName projectName) {
    final val =
        SettingsStore.sp().getString(projectName.settingPrefix() + super._key);
    return val != null
        ? NotificationFrequencyExt.getOptionFromString(val)
        : super._defaultVal;
  }

  @override
  Future<void> setValue(
      ProjectName projectName, NotificationFrequency? value) async {
    if (value == null) {
      notificationService.cancelNotification(projectName.name().hashCode);
    } else {
      notificationService.scheduleNotification(
          id: projectName.name().hashCode,
          title: "'${projectName.name()!}' Reminder",
          body: 'Remember to take a photo!',
          notificationFrequency: value);
    }
    await SettingsStore.sp().setString(projectName.settingPrefix() + super._key,
        value?.stringRepresentation() ?? "");
  }

  @override
  Widget getWidget(ProjectName projectName) {
    return NotificationFrequencyWidget(this, projectName);
  }
}

class NotificationFrequencyWidget extends StatefulWidget {
  final NotificationFrequencySetting _setting;
  final ProjectName _projectName;

  const NotificationFrequencyWidget(this._setting, this._projectName,
      {super.key});

  @override
  State<NotificationFrequencyWidget> createState() =>
      _NotificationFrequencySettingWidgetState();
}

const String neverEntry = "Never";

class _NotificationFrequencySettingWidgetState
    extends State<NotificationFrequencyWidget> {
  NotificationFrequency? _value;

  @override
  void initState() {
    _value = widget._setting.getValue(widget._projectName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            await widget._setting.setValue(widget._projectName, freqOpt);
            setState(() {
              _value = freqOpt;
            });
          },
          items: ([neverEntry] +
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
