import 'dart:math';

import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/frame_editor_page.dart';
import 'package:chronolapse/ui/pages/project_editor_page.dart';
import 'package:chronolapse/ui/shared/feature_points_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:chronolapse/util/shared_keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../test_utils/fake_data.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    print("Waiting for ADB to grant permissions");
    while (!(await Permission.camera.isGranted &&
        await Permission.microphone.isGranted)) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    print("ADB permissions granted");
  });
  testWidgets('Photo Editor - Editing First Frame',
      (WidgetTester tester) async {
    await setup();

    // Create fake project
    const projectName = "photoEditing1";
    await createFakeProject(projectName, 2);

    // Get UUID of 1nd frame
    final project = await TimelapseStore.getProject(projectName);
    final frameUuid = project.data.metaData.frames[0];

    // Enter frame editor
    await tester.pumpWidget(AppRoot(FrameEditor(projectName, frameUuid)));
    await tester.pumpAndSettle();

    // Testing - feature points visibility toggle

    // Disabling feature points
    await tester.tap(find.byKey(frameEditorFeaturePointsVisibilityToggleKey));
    await tester.pumpAndSettle();
    // Assert no feature points are found
    expect(find.byType(FeaturePointMarker), findsNothing);

    // Enabling feature points
    await tester.tap(find.byKey(frameEditorFeaturePointsVisibilityToggleKey));
    await tester.pumpAndSettle();
    // Assert feature points are found
    expect(find.byType(FeaturePointMarker), findsWidgets);

    // Testing - colour grading tab
    // Just verifying they don't throw

    await tester.tap(find.byKey(frameEditorColourGradingTabKey));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorBrightnessSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorContrastSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorWhiteBalanceSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorSaturationSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    // Testing - Alignment tab

    await tester.tap(find.byKey(frameEditorAlignmentTabKey));
    await tester.pumpAndSettle();

    // Assert that manual alignment toggle is not found
    // This toggle should not be available for the first frame
    expect(find.byKey(frameEditorManualAlignmentToggleKey), findsNothing);

    // Assert that we can move the feature points
    /*
    {
      final featurePoint = find.byKey(getFeaturePointMarkerKey(0));
      final position = tester.getCenter(featurePoint);

      // Drag point
      await tester.timedDrag(
          featurePoint, const Offset(10.0, 10.0), const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final newPosition =
          tester.getCenter(find.byKey(getFeaturePointMarkerKey(0)));

      expect(newPosition.dx, isNot(equals(position.dx)));
    }
    */

    // Testing - Save and exit

    await tester.tap(find.byKey(frameEditorSaveAndExitButtonKey));
    await tester.pumpAndSettle();

    // Assert that we arrived at the project editor page
    expect(find.byType(ProjectEditorPage), findsOne);
  });
  testWidgets('Photo Editor - Editing Subsequent Frame',
      (WidgetTester tester) async {
    await setup();

    await Future.delayed(const Duration(seconds: 1));

    // Create fake project
    const projectName = "photoEditing2";
    await createFakeProject(projectName, 2);

    // Get UUID of 2nd frame
    final project = await TimelapseStore.getProject(projectName);
    final frameUuid = project.data.metaData.frames[1];

    // Enter frame editor
    await tester.pumpWidget(AppRoot(FrameEditor(projectName, frameUuid)));
    await tester.pumpAndSettle();

    // Testing - feature points visibility toggle

    // Disabling feature points
    await tester.tap(find.byKey(frameEditorFeaturePointsVisibilityToggleKey));
    await tester.pumpAndSettle();
    // Assert no feature points are found
    expect(find.byType(FeaturePointMarker), findsNothing);

    // Enabling feature points
    await tester.tap(find.byKey(frameEditorFeaturePointsVisibilityToggleKey));
    await tester.pumpAndSettle();
    // Assert feature points are found
    expect(find.byType(FeaturePointMarker), findsWidgets);

    // Testing - colour grading tab
    // Just verifying they don't throw

    await tester.tap(find.byKey(frameEditorColourGradingTabKey));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorBrightnessSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorContrastSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorWhiteBalanceSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byKey(frameEditorSaturationSliderKey), const Offset(10.0, 0.0));
    await tester.pumpAndSettle();

    // Testing - Alignment tab

    await tester.tap(find.byKey(frameEditorAlignmentTabKey));
    await tester.pumpAndSettle();

    // Enable manual alignment
    await tester.tap(find.byKey(frameEditorManualAlignmentToggleKey));

    // Assert that we can move the feature points
    /*
    {
      final featurePoint = find.byKey(getFeaturePointMarkerKey(0));
      final position = tester.getCenter(featurePoint);

      // Drag point
      await tester.timedDrag(
          featurePoint, const Offset(10.0, 10.0), const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final newPosition =
          tester.getCenter(find.byKey(getFeaturePointMarkerKey(0)));

      expect(newPosition.dx, isNot(equals(position.dx)));
    }
     */

    // Disable manual alignment

    await tester.tap(find.byKey(frameEditorManualAlignmentToggleKey));

    // Assert that we can no longer move the feature points
    {
      final featurePoint = find.byKey(getFeaturePointMarkerKey(0));
      final position = tester.getCenter(featurePoint);

      // Drag point
      await tester.drag(featurePoint, const Offset(10.0, 10.0));
      await tester.pumpAndSettle();
      final newPosition =
          tester.getCenter(find.byKey(getFeaturePointMarkerKey(0)));

      expect((position.dx - newPosition.dx).abs(), lessThan(0.0001));
    }

    // Testing - Save and exit

    await tester.tap(find.byKey(frameEditorSaveAndExitButtonKey));
    await tester.pumpAndSettle();

    // Assert that we arrived at the project editor page
    expect(find.byType(ProjectEditorPage), findsOne);
  });
}
