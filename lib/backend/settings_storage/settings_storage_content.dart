import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/project_setting.dart';

List<WidgetSettingGlobal> availableGlobalSettings = [
  exampleToggleSetting.asWidgetOnly(),
  const WidgetSettingGlobal(DividerNoSetting()),
];

List<WidgetSettingRequiresProject> availableProjectSettings = [
  exampleToggleSettingTwo.asWidgetOnly(),
  const WidgetSettingRequiresProject(DividerNoSetting()),
];

const exampleToggleSetting = Global(ToggleSetting("exampleToggle", false));

const exampleToggleSettingTwo =
    RequiresProject(ToggleSetting("exampleToggleTwo", true));
