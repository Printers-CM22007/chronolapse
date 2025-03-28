part of 'project_setting.dart';

class DividerNoSetting extends SettingWidget<None> {
  const DividerNoSetting() : super("", const None());

  @override
  Widget getWidget(ProjectName projectName) {
    return const Divider();
  }
}
