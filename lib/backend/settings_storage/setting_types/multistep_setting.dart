part of 'project_setting.dart';

class MultistepSetting extends PersistentSetting<int> {
  final List<int> _allowedValues;
  final String _title;
  final String _valuePrefix;
  final String _valueSuffix;
  const MultistepSetting(super._key, super._defaultValue, allowedValues, title,
      valuePrefix, valueSuffix)
      : _allowedValues = allowedValues,
        _title = title,
        _valuePrefix = valuePrefix,
        _valueSuffix = valueSuffix;

  @override
  int getValue(ProjectName projectName) {
    final val =
        SettingsStore.sp().getInt(projectName.settingPrefix() + super._key);
    return val ?? _allowedValues[super._defaultVal];
  }

  @override
  Future<void> setValue(ProjectName projectName, int value) async {
    await SettingsStore.sp()
        .setInt(projectName.settingPrefix() + super._key, value);
  }

  @override
  Widget getWidget(ProjectName projectName) {
    return MultistepWidget(this, projectName);
  }
}

class MultistepWidget extends StatefulWidget {
  final MultistepSetting _setting;
  final ProjectName _projectName;

  const MultistepWidget(this._setting, this._projectName, {super.key});

  @override
  State<MultistepWidget> createState() => _MultistepWidgetState();
}

class _MultistepWidgetState extends State<MultistepWidget> {
  late int _value;
  late double _fakeValue;

  @override
  void initState() {
    _value = widget._setting.getValue(widget._projectName);
    _fakeValue = (widget._setting._allowedValues.indexOf(_value).toDouble() /
            (widget._setting._allowedValues.length.toDouble() - 1)) *
        100;
    super.initState();
  }

  int _findClosestValue(double value) {
    value /= 100;
    value *= widget._setting._allowedValues.length.toDouble() - 1;
    print(value);
    return widget._setting._allowedValues[value.round()];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget._setting._title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: _fakeValue,
            min: 0,
            max: 100,
            divisions: widget._setting._allowedValues.length - 1,
            label: _value.toString(),
            onChanged: (value) {
              setState(() {
                _value = _findClosestValue(value);
                _fakeValue = value;
                widget._setting.setValue(widget._projectName, _value);
              });
            },
          ),
          Text(
              '${widget._setting._valuePrefix}${_value.toInt()}${widget._setting._valueSuffix}'),
        ],
      ),
    );
  }
}
