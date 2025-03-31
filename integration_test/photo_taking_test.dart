import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/pages/photo_preview_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:chronolapse/ui/pages/project_editor_page.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

import 'package:chronolapse/util/shared_keys.dart';
import 'package:permission_handler/permission_handler.dart';

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
  testWidgets('Photo Taking Page - Taking Photo', (WidgetTester tester) async {
    await setup();

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    // Create a project
    const uuid = Uuid();
    final projectName = uuid.v4();
    await TimelapseStore.createProject(projectName);

    await tester.pumpWidget(AppRoot(PhotoTakingPage(projectName)));
    await tester.pumpAndSettle();

    // Find and press shutter button
    await tester.tap(find.byKey(photoTakingShutterButtonKey).first);
    await tester.pumpAndSettle();

    // Assert that we proceeded to the photo preview page
    expect(find.byType(PhotoPreviewPage), findsOne);

    await tester.pumpAndSettle();
  });
  testWidgets('Photo Taking Page - Navigate to Edit Frames Page',
      (WidgetTester tester) async {
    await setup();

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    // Create a project
    const uuid = Uuid();
    final projectName = uuid.v4();
    await TimelapseStore.createProject(projectName);

    await tester.pumpWidget(AppRoot(PhotoTakingPage(projectName)));
    await tester.pumpAndSettle();

    // Tap photo
    await tester.tap(find.byKey(projectNavigationBarEditKey));
    await tester.pumpAndSettle();

    // Expect to end up in edit page
    expect(find.byType(ProjectEditorPage), findsOne);
  });
  testWidgets('Photo Taking Page - Navigate to Export Page',
      (WidgetTester tester) async {
    await setup();

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    // Create a project
    const uuid = Uuid();
    final projectName = uuid.v4();
    await TimelapseStore.createProject(projectName);

    await tester.pumpWidget(AppRoot(PhotoTakingPage(projectName)));
    await tester.pumpAndSettle();

    // Tap photo
    await tester.tap(find.byKey(projectNavigationBarExportKey));
    await tester.pumpAndSettle();

    // Expect to end up in edit page
    expect(find.byType(ProjectEditorPage), findsOne);
  });
}
