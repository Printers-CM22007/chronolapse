import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:chronolapse/util/uninitialised_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    await tester.enterText(find.byKey(const Key("newProjectTextField")), "testProject&");
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
    await tester.enterText(find.byKey(const Key("newProjectTextField")), "testProject");
    await tester.pumpAndSettle();
    await tester.tap(find.text("Create"));
    await tester.pumpAndSettle();
    expect(find.text("New Project"), findsNothing);
    expect(find.text("testProject"), findsOne);
    expect(find.text("Tap to take photo"), findsOne);
    expect(find.textContaining("Edited a moment ago"), findsOne);

    // Filter results
    expect(find.text("Search Project"), findsOne);
    await tester.enterText(find.byKey(const Key("searchProjectsTextField")), "t");
    await tester.pumpAndSettle();
    expect(find.text("testProject"), findsOne);
    await tester.enterText(find.byKey(const Key("searchProjectsTextField")), "&&");
    await tester.pumpAndSettle();
    expect(find.text("testProject"), findsNothing);
  });
}
