import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';

// List of global settings (as well as decorations) available in the settings
// page
List<WidgetSettingGlobal> availableGlobalSettings = [
  exampleToggleSetting.asWidgetOnly(),
  const WidgetSettingGlobal(DividerNoSetting()),
];

// List of project settings (as well as decorations) available in the settings
// page
List<WidgetSettingRequiresProject> availableProjectSettings = [
  exampleToggleSettingTwo.asWidgetOnly(),
  const WidgetSettingRequiresProject(DividerNoSetting()),
];

// Global Settings
const exampleToggleSetting = Global(ToggleSetting("exampleToggle", false));

// Project Settings
const exampleToggleSettingTwo =
    RequiresProject(ToggleSetting("exampleToggleTwo", true));
