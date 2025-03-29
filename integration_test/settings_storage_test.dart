import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/util/uninitialised_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Settings Store Uninitialised Test', (WidgetTester tester) async {
    expect(() async => await SettingsStore.deleteAllSettings(),
        throwsA(isA<UninitialisedException>()));
  });
  testWidgets('Settings Store Value Changing Tests', (WidgetTester tester) async {
    await SettingsStore.initialise();
    const testToggleGlobalSetting = Global(ToggleSetting(
        "testToggleProjectSetting",
        true,
        "Example Toggle Two",
        "Also does nothing"));
    final testToggleProjectSetting = const RequiresProject(ToggleSetting(
            "testToggleGlobalSetting",
            true,
            "Example Toggle Two",
            "Also does nothing"))
        .withProject(const ProjectName("testProject"));
    final testLastModifiedProjectSetting =
        const RequiresProject(LastModifiedNoWidget("testLastModifiedProject"))
            .withProject(const ProjectName("testProject"));

    expect(testLastModifiedProjectSetting.getValue(), 0);
    expect(() => testLastModifiedProjectSetting.getWidget(), throwsA(isA<Exception>()));

    testToggleGlobalSetting.setValue(false);
    testToggleProjectSetting.setValue(false);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    testLastModifiedProjectSetting.setValue(nowMs);

    expect(testToggleGlobalSetting.getValue(), false);
    expect(testToggleProjectSetting.getValue(), false);
    expect(testLastModifiedProjectSetting.getValue(), nowMs);

    await SettingsStore.deleteAllGlobalSettings();

    expect(testToggleGlobalSetting.getValue(), true);
    expect(testToggleProjectSetting.getValue(), false);
    expect(testLastModifiedProjectSetting.getValue(), nowMs);

    testToggleGlobalSetting.setValue(false);
    testToggleProjectSetting.setValue(false);

    await SettingsStore.deleteAllProjectSettings("testProject");

    expect(testToggleGlobalSetting.getValue(), false);
    expect(testToggleProjectSetting.getValue(), true);
    expect(testLastModifiedProjectSetting.getValue(), 0);

    await SettingsStore.deleteAllSettings();

    expect(testToggleGlobalSetting.getValue(), true);
    expect(testToggleProjectSetting.getValue(), true);
    expect(testLastModifiedProjectSetting.getValue(), 0);
  });
}
