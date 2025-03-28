import 'dart:io';
import 'dart:math';

import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/backend/video_generator/frame_transformer.dart';
import 'package:chronolapse/native_methods/video_compiler.dart';
import 'package:path_provider/path_provider.dart';

class VideoGenerationResult {
  final String? path;
  final String? error;

  const VideoGenerationResult._(this.path, this.error);
  const VideoGenerationResult.path(this.path) : error = null;
  const VideoGenerationResult.error(this.error) : path = null;
}

const String framesFolderName = "frames";
const String outputsFolderName = "outputs";

Future<void> cleanupGeneratedVideo() async {
  final videoDirectory = Directory("${(await getApplicationCacheDirectory()).path}/$outputsFolderName");

  if (!await videoDirectory.exists()) { return; }

  final videoDirs = await videoDirectory.list().toList();

  for (final entry in videoDirs) {
    entry.delete(recursive: true);
  }
}

Future<VideoGenerationResult> generateVideo(
    String projectName, Function(String) progressCallback) async {
  final projectData = await TimelapseStore.getProject(projectName);
  final frameList = projectData.data.metaData.frames;

  progressCallback("Setting up directory structure...");

  final frameDir = Directory(
      "${(await getApplicationCacheDirectory()).path}/$framesFolderName");
  if (await frameDir.exists()) {
    await frameDir.delete(recursive: true);
  }
  await frameDir.create(recursive: true);

  const int minId = 10 ^ 8;
  const int maxId = 10 ^ 9;
  final int outputId = minId + Random().nextInt(maxId - minId);
  final outputDir = Directory(
      "${(await getApplicationCacheDirectory()).path}/$outputsFolderName/$outputId");
  if (await outputDir.exists()) {
    await outputDir.delete(recursive: true);
  }
  await outputDir.create(recursive: true);
  final outputFile = "${outputDir.path}/$projectName.mp4";

  final transformResult = await transformFrames(
      projectName, frameList, frameDir.path, progressCallback);
  if (!transformResult) {
    return const VideoGenerationResult.error("Failed to transform frames");
  }

  progressCallback("Compiling frames into video...");

  final compileResult =
      await compileVideo(frameDir.path, frameList.length, outputFile, projectName);
  if (compileResult == null) {
    return const VideoGenerationResult.error(
        "Failed to compile frames into video");
  }

  progressCallback("Cleaning up...");

  await frameDir.delete(recursive: true);

  return VideoGenerationResult.path(compileResult);
}
