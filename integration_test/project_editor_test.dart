import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/pages/frame_editor_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:chronolapse/ui/pages/project_editor_page.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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
  testWidgets('Dashboard Page Test', (WidgetTester tester) async {
    await setup();

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    final testProject = await createFakeProject("testProject", 3);

    await tester.pumpWidget(const AppRoot(ProjectEditorPage("testProject")));
    await tester.pumpAndSettle();

    // Wait to settle
    await Future.delayed(const Duration(seconds: 2));

    // Find delete buttons and sort by y-position
    final List<MapEntry<Element, double>> deleteButtons = find.byIcon(Icons.delete)
        .evaluate()
        .map((e) => MapEntry(e, tester.getTopLeft(find.byElementPredicate((el) => el == e)).dy))
        .toList();
    deleteButtons.sort((a, b) => a.value.compareTo(b.value));

    expect(deleteButtons.length, 3);

    // Test first frame deletion protection
    await tester.tap(find.byElementPredicate((el) => el == deleteButtons[0].key));
    await tester.pumpAndSettle();
    expect(find.text(cannotDeleteFirstFrameText), findsOne);

    await Future.delayed(const Duration(seconds: 1));

    // Test delete button
    expect(find.text("Deleting Frame 2"), findsNothing);
    await tester.tap(find.byElementPredicate((el) => el == deleteButtons[1].key));
    await tester.pumpAndSettle();
    expect(find.text("Deleting Frame 2"), findsOne);

    // Test cancel delete
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
    await testProject.reloadFromDisk();
    expect(testProject.data.metaData.frames.length, 3);
    expect(find.text("Deleting Frame 2"), findsNothing);

    // Test deleting
    await tester.tap(find.byElementPredicate((el) => el == deleteButtons[1].key));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle();
    await testProject.reloadFromDisk();
    expect(testProject.data.metaData.frames.length, 2);
    expect(find.byIcon(Icons.delete), findsExactly(2));

    // Test settings button
    expect(find.byType(SettingsPage), findsNothing);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOne);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);

    // Test frame edit button
    expect(find.byType(FrameEditor), findsNothing);
    await tester.tap(find.byKey(projectEditorFrameEditButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(FrameEditor), findsOne);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(FrameEditor), findsNothing);

    // Test export button
    expect(find.byType(ExportPage), findsNothing);
    await tester.tap(find.text("Export"));
    await tester.pumpAndSettle();
    expect(find.byType(ExportPage), findsOne);
    await tester.tap(find.text("Edit frames"));
    await tester.pumpAndSettle();
    expect(find.byType(ExportPage), findsNothing);

    // Test take photo button
    expect(find.byType(PhotoTakingPage), findsNothing);
    await tester.tap(find.text("Take photo"));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoTakingPage), findsOne);
    await tester.tap(find.text("Edit frames"));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoTakingPage), findsNothing);
  });
}
