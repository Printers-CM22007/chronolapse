
import 'package:chronolapse/backend/settings_storage/settings_storage.dart';
import 'package:chronolapse/backend/settings_storage/settings_storage_types.dart';
import 'package:flutter/material.dart';

const List<PersistentSetting> availableGlobalSettings = [
  exampleToggleSetting
];

const List<PersistentSetting> availableProjectSettings = [
  exampleToggleSettingTwo
];

const exampleToggleSetting = ToggleSetting("exampleToggle", false);
const exampleToggleSettingTwo = ToggleSetting("exampleToggleTwo", true);