part of 'project_setting.dart';

class TitleNoSetting extends SettingWidget<None> {
  final String _title;
  const TitleNoSetting(this._title) : super("", const None());

  @override
  Widget getWidget(ProjectName projectName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: Text(
        _title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 100, 100, 100)),
      )),
    );
  }
}
