import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';

// List of global settings (as well as decorations) available in the settings
// page
List<WidgetSettingGlobal> availableGlobalSettings = [
  const WidgetSettingGlobal(TitleNoSetting("Global Settings")),
  referenceOverlayOpacity.asWidgetOnly(),
];

// List of project settings (as well as decorations) available in the settings
// page
List<WidgetSettingRequiresProject> availableProjectSettings = [
  const WidgetSettingRequiresProject(TitleNoSetting("Project Settings")),
  notificationFrequencySetting.asWidgetOnly(),
  fpsSetting.asWidgetOnly(),
  bitRateSetting.asWidgetOnly(),
];

// ! Use only alphanumeric characters in setting keys!

// Global Settings **************

const referenceOverlayOpacity = Global(MultistepSetting(
    "referenceOverlayOpacity",
    3,
    [0, 10, 20, 30, 40, 50, 60, 70, 80],
    "Alignment Overlay Opacity",
    "",
    "% selected"));

// Project Settings **************

const notificationFrequencySetting = RequiresProject(
    NotificationFrequencySetting("notificationFrequency", null));

const fpsSetting = RequiresProject(MultistepSetting(
    "videoFps",
    6,
    [1, 2, 3, 5, 10, 20, 30, 45, 60, 90, 120],
    "Generated Video FPS",
    "",
    " FPS selected"));

const bitRateSetting = RequiresProject(MultistepSetting(
    "videoBitrate",
    3,
    [1024, 2048, 4096, 8192, 16384],
    "Generated Video Bitrate",
    "",
    " bits/s selected"));

// ! Do not show these in the settings page
// Hidden Settings **************
const lastModifiedProject =
    RequiresProject(LastModifiedNoWidget("lastModified"));
