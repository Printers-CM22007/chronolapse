import 'dart:io';

import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/util/uninitialised_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../test_utils/test_utils.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Timelapse Store Uninitialised Test',
      (WidgetTester tester) async {
    expect(() async => await TimelapseStore.getProject("testProject"),
        throwsA(isA<UninitialisedException>()));
  });
  testWidgets('Timelapse Store Project Tests', (WidgetTester tester) async {
    await SettingsStore.initialise();
    await TimelapseStore.initialise();

    // Test getProjectList
    await TimelapseStore.deleteAllProjects();
    expect(TimelapseStore.getProjectList(), isEmpty);

    await TimelapseStore.createProject("testProjectTwo");
    await TimelapseStore.initialise();

    expect(TimelapseStore.getProjectList(), isNotEmpty);

    await TimelapseStore.deleteAllProjects();
    await SettingsStore.deleteAllSettings();

    expect(TimelapseStore.getProjectList(), isEmpty);

    // Create project and run functions on it
    await TimelapseStore.createProject("testProject");

    expect(TimelapseStore.getProjectList(), isNotEmpty);

    final projectData = await TimelapseStore.getProject("testProject");

    // Test TimelapseData changing
    expect(projectData.data.metaData.frames, isEmpty);

    final projectDataTwo = await TimelapseStore.getProject("testProject");
    projectDataTwo.data.metaData.frames.add("testID");
    await projectDataTwo.saveChanges();

    expect(projectData.data.metaData.frames, isEmpty);
    await projectData.reloadFromDisk();
    expect(projectData.data.metaData.frames, isNotEmpty);

    await TimelapseStore.deleteProject("testProject");
    expect(TimelapseStore.getProjectList(), isEmpty);
  });
  testWidgets('Timelapse Frame Tests', (WidgetTester tester) async {
    final exampleImageOne = generateRandomBytes(1024);
    final exampleImageTwo = generateRandomBytes(1024);

    await TimelapseStore.initialise();
    await TimelapseStore.deleteAllProjects();

    final project = (await TimelapseStore.createProject("testProject"))!;
    expect(project.data.metaData.frames, isEmpty);

    // Create frame
    final frame =
        TimelapseFrame.createNew("testProject", FrameTransform.baseFrame());
    // Not saved yet so uuid usage should throw
    expect(() => frame.getFramePng(), throwsA(isA<NoUuidException>()));
    // Not saved yet so uuid usage should throw
    expect(() => frame.saveFrameDataOnly(), throwsA(isA<Exception>()));

    // Uuid obtained after image is saved
    await frame.saveFrameFromPngBytes(exampleImageOne);
    await project.reloadFromDisk();
    expect(frame.uuid(), isNotNull);
    expect(project.data.metaData.frames, contains(frame.uuid()!));

    // Load frame from disk
    final frameFromDisk =
        await TimelapseFrame.fromExisting("testProject", frame.uuid()!);

    // Change FrameData
    frameFromDisk.data.frameTransform =
        FrameTransform.autoGenerated(Homography.identity());
    await frameFromDisk.saveFrameDataOnly();
    expect(frame.data.frameTransform.isKnown, true);
    // FrameData updates after reloadFromDisk
    await frame.reloadFromDisk();
    expect(frame.data.frameTransform.isKnown, false);

    // Check that path and image saved are correct
    expect(frame.getFramePng().path, contains(frame.uuid()));
    expect(await frame.getFramePng().readAsBytes(), exampleImageOne);

    // Check deleting frame
    final framePngFile = frame.getFramePng();
    final frameUuid = frame.uuid()!;
    await frame.deleteFrame();
    expect(await framePngFile.exists(), false);

    // Frame should also be removed from project
    await project.reloadFromDisk();
    expect(project.data.metaData.frames, isNot(contains(frameUuid)));
    expect(frame.uuid(), isNull);

    // Save frame from file
    final exampleImageTwoPath =
        "${(await getApplicationCacheDirectory()).path}/test-png.png";
    await File(exampleImageTwoPath).writeAsBytes(exampleImageTwo);
    await frame.saveFrameFromPngFile(File(exampleImageTwoPath));
    expect(await frame.getFramePng().readAsBytes(), exampleImageTwo);

    // Create frame with data
    final frameTwo = TimelapseFrame.createNewWithData("testProject",
        FrameData.initial("testProject", FrameTransform.baseFrame()));
    expect(frameTwo.data.frameTransform.isKnown, true);
  });
}
