import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';

List<WidgetSettingGlobal> availableGlobalSettings = [
  const WidgetSettingGlobal(TitleNoSetting("Global Settings")),
  exampleToggleSetting.asWidgetOnly(),
  const WidgetSettingGlobal(DividerNoSetting()),
];

List<WidgetSettingRequiresProject> availableProjectSettings = [
  const WidgetSettingRequiresProject(TitleNoSetting("Project Settings")),
  exampleToggleSettingTwo.asWidgetOnly(),
  const WidgetSettingRequiresProject(DividerNoSetting()),
];

// Global Settings
const exampleToggleSetting = Global(
    ToggleSetting("exampleToggle", false, "Example Toggle", "Does nothing"));

// Project Settings
const exampleToggleSettingTwo = RequiresProject(ToggleSetting(
    "exampleToggleTwo", true, "Example Toggle Two", "Also does nothing"));
