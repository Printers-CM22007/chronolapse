import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:flutter/material.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Generate Video', (WidgetTester tester) async {
    await setup();

    await TimelapseStore.initialise();
    await TimelapseStore.deleteAllProjects();

    await tester.pumpWidget(const AppRoot(DashboardPage()));
    await tester.pumpAndSettle();

    // Creates new project

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

    // Take first photo

    await tester.tap(find.textContaining("take photo").first);
    await tester.pumpAndSettle();
    expect(find.byType(PhotoTakingPage), findsOne);

    await tester.tap(find.byKey(photoTakingShutterButtonKey));
    // waits for response from the camera API
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text("Continue"), findsOne);
    await tester.tap(find.text("Continue"));
    await tester.pumpAndSettle();

    expect(find.text("Place at least 4 markers on the image"), findsOne);
    await tester.tap(find.byKey(featurePointsEditorKey));
    await tester.tap(find.byKey(featurePointsEditorKey));
    await tester.tap(find.byKey(featurePointsEditorKey));
    await tester.tap(find.byKey(featurePointsEditorKey));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Save and continue"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Save and exit"));
    await tester.pumpAndSettle();

    // Take second photo

    await tester.tap(find.text("Edit"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Take photo"));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(photoTakingShutterButtonKey));
    // waits for response from the camera API
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text("Continue"), findsOne);
    await tester.tap(find.text("Continue"));
    await tester.pumpAndSettle();
  });
}
