import 'dart:io';

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
  testWidgets('Photo Taking Page - Navigate to Export Page',
      (WidgetTester tester) async {
    await setup();

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    // Create project in Dashboard page
    await tester.pumpWidget(const AppRoot(DashboardPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Create New"));
    await tester.pumpAndSettle();

    expect(find.text("New Project"), findsOne);

    await tester.enterText(find.byKey(newProjectTextFieldKey), "testProject");
    await tester.pumpAndSettle();
    await tester.tap(find.text("Create"));
    await tester.pumpAndSettle();

    expect(find.text("testProject"), findsOne);
    expect(find.text("Tap to take photo"), findsOne);
    expect(find.textContaining("Edited a moment ago"), findsOne);

    // Enter photo taking page
    await tester.tap(find.textContaining("take photo").first);
    await tester.pumpAndSettle();
    expect(find.byType(PhotoTakingPage), findsOne);

    // Tap navigation option
    await tester.tap(find.byKey(projectNavigationBarExportKey));
    await tester.pumpAndSettle();

    // Expect to end up in export page
    expect(find.byType(ExportPage), findsOne);
  });
}
