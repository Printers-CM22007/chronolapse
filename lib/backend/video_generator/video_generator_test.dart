import '../settings_storage/settings_store.dart';
import '../timelapse_storage/timelapse_store.dart';

Future<void> testVideoGenerator() async {
  print("Starting video generator test");

  await TimelapseStore.deleteAllProjects();
  await SettingsStore.deleteAllSettings();

  final testProject = (await TimelapseStore.createProject("testProject"))!;

  await TimelapseStore.deleteAllProjects();
}
