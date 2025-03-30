import 'dart:io';

import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:chronolapse/ui/pages/project_editor_page.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:chronolapse/util/shared_keys.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    print("Waiting for ADB to grant permissions");
    while (!(await Permission.camera.isGranted && await Permission.microphone.isGranted)) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    print("ADB permissions granted");
  });
  testWidgets('Dashboard Page Test', (WidgetTester tester) async {
    await setup();

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    await tester.pumpWidget(const AppRoot(DashboardPage()));
    await tester.pumpAndSettle();

    // No projects text
    expect(find.textContaining("No projects"), findsOne);

    // No dialog
    expect(find.textContaining("New Project"), findsNothing);

    // Open dialog
    await tester.tap(find.text("Create New"));
    await tester.pumpAndSettle();

    // See dialog
    expect(find.text("New Project"), findsOne);

    // Try entering invalid name
    await tester.enterText(find.byKey(newProjectTextFieldKey), "testProject&");
    await tester.pumpAndSettle();

    // Create fails
    await tester.tap(find.text("Create"));
    await tester.pumpAndSettle();
    expect(find.text("New Project"), findsOne);

    // Closes dialog
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
    expect(find.text("New Project"), findsNothing);

    // Reopens dialog
    await tester.tap(find.text("Create New"));
    await tester.pumpAndSettle();

    // Enter valid name and create
    await tester.enterText(find.byKey(newProjectTextFieldKey), "testProject");
    await tester.pumpAndSettle();
    await tester.tap(find.text("Create"));
    await tester.pumpAndSettle();
    expect(find.text("New Project"), findsNothing);
    expect(find.text("testProject"), findsOne);
    expect(find.text("Tap to take photo"), findsOne);
    expect(find.textContaining("Edited a moment ago"), findsOne);

    // Filter results
    expect(find.text("Search Project"), findsOne);
    await tester.enterText(find.byKey(searchProjectsTextFieldKey), "t");
    await tester.pumpAndSettle();
    expect(find.text("testProject"), findsOne);
    await tester.enterText(find.byKey(searchProjectsTextFieldKey), "&&");
    await tester.pumpAndSettle();
    expect(find.text("testProject"), findsNothing);
    await tester.enterText(find.byKey(searchProjectsTextFieldKey), "");
    await tester.pumpAndSettle();
    expect(find.text("testProject"), findsOne);

    // Open settings page
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(popupMenuSettingsIconKey));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Open export page
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Export"));
    await tester.pumpAndSettle();
    expect(find.byType(ExportPage), findsOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Delete project
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle();
    expect(find.textContaining("Deleting"), findsOne);
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
    expect(find.textContaining("Deleting"), findsNothing);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dashboardConfirmDeleteKey));
    await tester.pumpAndSettle();
    expect(find.text("testProject"), findsNothing);

    // No projects text reappears
    expect(find.textContaining("No projects"), findsOne);

    // Create two projects
    await tester.tap(find.text("Create New"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(newProjectTextFieldKey), "testProjectTwo");
    await tester.pumpAndSettle();
    await tester.tap(find.text("Create"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Create New"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(newProjectTextFieldKey), "testProjectThree");
    await tester.pumpAndSettle();
    await tester.tap(find.text("Create"));
    await tester.pumpAndSettle();

    // Edit project
    await tester.tap(find.text("Edit").first);
    await tester.pumpAndSettle();
    expect(find.byType(ProjectEditorPage), findsOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Take photo
    await tester.tap(find.textContaining("take photo").first);
    await tester.pumpAndSettle();
    expect(find.byType(PhotoTakingPage), findsOne);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Go to settings page
    await tester.tap(find.byKey(dashboardNavigationSettingsKey));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOne);
  });
}
