import 'dart:io';
import 'dart:math';

import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/backend/video_generator/frame_transformer.dart';
import 'package:chronolapse/native_methods/video_compiler.dart';
import 'package:path_provider/path_provider.dart';

/// Result of video generation
class VideoGenerationResult {
  final String? path;
  final String? error;

  const VideoGenerationResult._(this.path, this.error);
  const VideoGenerationResult.path(this.path) : error = null;
  const VideoGenerationResult.error(this.error) : path = null;
}

const String framesFolderName = "frames";
const String outputsFolderName = "outputs";

/// Cleans up any past videos that have been generated. Partially blocking -
/// obtaining files to delete is awaited but deleting files is not.
Future<void> cleanupGeneratedVideo() async {
  final videoDirectory = Directory(
      "${(await getApplicationCacheDirectory()).path}/$outputsFolderName");

  if (!await videoDirectory.exists()) {
    return;
  }

  final videoDirs = await videoDirectory.list().toList();

  for (final entry in videoDirs) {
    entry.delete(recursive: true);
  }
}

/// Generates a video for a project
Future<VideoGenerationResult> generateVideo(
    String projectName, Function(String) progressCallback) async {
  final projectData = await TimelapseStore.getProject(projectName);
  final frameList = projectData.data.metaData.frames;

  progressCallback("Setting up directory structure...");

  // Create directory for transformed frames
  final frameDir = Directory(
      "${(await getApplicationCacheDirectory()).path}/$framesFolderName");
  if (await frameDir.exists()) {
    await frameDir.delete(recursive: true);
  }
  await frameDir.create(recursive: true);

  // Create directory for output video
  final int minId = pow(10, 8).toInt();
  final int maxId = pow(10, 9).toInt();
  final int outputId = minId + Random().nextInt(maxId - minId);
  print(outputId);
  final outputDir = Directory(
      "${(await getApplicationCacheDirectory()).path}/$outputsFolderName/$outputId");
  if (await outputDir.exists()) {
    await outputDir.delete(recursive: true);
  }
  await outputDir.create(recursive: true);
  final outputFile = "${outputDir.path}/$projectName.mp4";

  // Transform frames
  final transformResult = await transformFrames(
      projectName, frameList, frameDir.path, progressCallback);
  if (!transformResult) {
    return const VideoGenerationResult.error("Failed to transform frames");
  }

  progressCallback("Compiling frames into video...");

  // Generate video
  final compileResult = await compileVideo(
      frameDir.path, frameList.length, outputFile, projectName);

  // Cleanup transformed frames
  progressCallback("Cleaning up...");
  await frameDir.delete(recursive: true);

  if (compileResult == null) {
    return const VideoGenerationResult.error(
        "Failed to compile frames into video");
  }

  return VideoGenerationResult.path(compileResult);
}
