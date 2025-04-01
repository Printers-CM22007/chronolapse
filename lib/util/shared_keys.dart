import 'package:flutter/material.dart';

// Keys used for testing, doesn't need to be covered
// coverage:ignore-file

// Dashboard
const newProjectTextFieldKey = Key("newProjectTextField");
const searchProjectsTextFieldKey = Key("searchProjectsTextField");
const popupMenuSettingsIconKey = Key("popupMenuSettingsIcon");
const dashboardConfirmDeleteKey = Key("dashboardConfirmDelete");

// Dashboard navigation bar
const dashboardNavigationSettingsKey = Key("dashboardNavigationSettings");

// Project navigation bar
const projectNavigationBarPhotoTakingKey =
    Key("projectNavigationBarPhotoTaking");
const projectNavigationBarEditKey = Key("projectNavigationBarEdit");
const projectNavigationBarExportKey = Key("projectNavigationBarExport");

// Photo taking page
const photoTakingShutterButtonKey = Key("photoTakingShutterButton");

// Feature points editor
const featurePointsEditorKey = Key("featurePointsEditorKey");

// Frame editor
const frameEditorSaveAndExitButtonKey = Key("frameEditorSaveAndExitButton");
const frameEditorColourGradingTabKey = Key("frameEditorColourGradingTab");
const frameEditorAlignmentTabKey = Key("frameEditorAlignmentTab");
const frameEditorBrightnessSliderKey = Key("frameEditorBrightnessSlider");
const frameEditorContrastSliderKey = Key("frameEditorContrastSlider");
const frameEditorWhiteBalanceSliderKey = Key("frameEditorWhiteBalanceSlider");
const frameEditorSaturationSliderKey = Key("frameEditorSaturationSlider");
const frameEditorFeaturePointsVisibilityToggleKey =
    Key("frameEditorVisibilityToggle");
const frameEditorManualAlignmentToggleKey =
    Key("frameEditorManualAlignmentToggle");

Key getSliderKey(String key) => Key("${key}Slider");
Key getFeaturePointMarkerKey(int index) => Key("featurePointMarker$index");
