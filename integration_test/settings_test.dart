import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Global-only Settings Test', (WidgetTester tester) async {
    await tester.pumpWidget(const AppRoot(SettingsPage(null)));
    await tester.pumpAndSettle();

    expect(find.text("Global Settings"), findsOneWidget);
    expect(find.text("Project Settings"), findsNothing);
  });
  testWidgets('Active Settings Test', (WidgetTester tester) async {
    await SettingsStore.initialise();
    await SettingsStore.deleteAllSettings();

    await tester.pumpWidget(const AppRoot(SettingsPage("exampleProject")));
    await tester.pumpAndSettle();

    expect(find.text("Global Settings"), findsOneWidget);
    expect(find.text("Project Settings"), findsOneWidget);
  });
  testWidgets('Unused Settings Test', (WidgetTester tester) async {
    await SettingsStore.initialise();
    await SettingsStore.deleteAllSettings();

    const exampleToggleSetting = Global(
        ToggleSetting("exampleToggle", false, "Example Toggle One", "Does nothing"));
    const exampleToggleSettingTwo = RequiresProject(ToggleSetting(
        "exampleToggleTwo", true, "Example Toggle Two", "Also does nothing"));

    await tester.pumpWidget(AppRoot(SettingsPage("exampleProject", globalSettings: [exampleToggleSetting.asWidgetOnly()], projectSettings: [exampleToggleSettingTwo.asWidgetOnly()])));
    await tester.pumpAndSettle();

    expect(exampleToggleSetting.getValue(), false);
    expect(exampleToggleSettingTwo.withProject(const ProjectName("exampleProject")).getValue(), true);

    final toggleOneFinder = find.text("Example Toggle One");
    final toggleTwoFinder = find.text("Example Toggle Two");

    expect(toggleOneFinder, findsOneWidget);
    expect(toggleTwoFinder, findsOneWidget);

    await tester.tap(toggleOneFinder);
    await tester.pumpAndSettle();
    expect(exampleToggleSetting.getValue(), true);

    await tester.tap(toggleTwoFinder);
    await tester.pumpAndSettle();
    expect(exampleToggleSettingTwo.withProject(const ProjectName("exampleProject")).getValue(), false);
  });
}