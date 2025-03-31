import 'package:flutter/material.dart';

// Keys used for testing, doesn't need to be covered
// coverage:ignore-file

const newProjectTextFieldKey = Key("newProjectTextField");
const searchProjectsTextFieldKey = Key("searchProjectsTextField");
const popupMenuSettingsIconKey = Key("popupMenuSettingsIcon");
const dashboardConfirmDeleteKey = Key("dashboardConfirmDelete");
const dashboardNavigationSettingsKey = Key("dashboardNavigationSettings");
const photoTakingShutterButtonKey = Key("photoTakingShutterButtonKey");
const featurePointsEditorKey = Key("featurePointsEditorKey");

Key getSliderKey(String key) => Key("${key}Slider");
