import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/util/uninitialised_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('A', (WidgetTester tester) async {
    expect(() async => await TimelapseStore.getProject("testProject"),
        throwsA(isA<UninitialisedException>()));
  });
  testWidgets('B', (WidgetTester tester) async {
    await SettingsStore.initialise();
    await TimelapseStore.initialise();

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    expect(TimelapseStore.getProjectList(), isEmpty);

    await TimelapseStore.createProject("testProject");

    final projectData = await TimelapseStore.getProject("testProject");

    expect(projectData.data.metaData.frames, isEmpty);
  });
}
