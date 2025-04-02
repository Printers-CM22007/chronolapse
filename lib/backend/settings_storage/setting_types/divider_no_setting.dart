part of 'project_setting.dart';

/// Divider line with no setting
class DividerNoSetting extends SettingWidget<None> {
  const DividerNoSetting() : super("", const None());

  @override
  Widget getWidget(ProjectName projectName) {
    return const Divider();
  }
}
