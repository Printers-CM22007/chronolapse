import 'dart:io';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ExportOptions {
  Future<void> downloadVideo(projectName) async {
    try {

      await TimelapseStore.initialise();
      Directory projectDir = TimelapseStore.getProjectDir(projectName);

      // FILE NAME SHARING PROJECT NAME?
      String videoFileName = projectName + ".mp4";
      File videoFile = File("${projectDir.path}/$videoFileName");

      if (!await videoFile.exists()) {
        print("Video file doesn't exist");
        return;

        /*try {
          await createExampleVideo(projectName);
        } catch (e, stacktrace) {
          print("didn't create: $e");
          print("TRACE: $stacktrace");
        }*/
      }

      Directory? downloadDirectory = await getDownloadsDirectory();
      if (downloadDirectory == null) {
        print("Device's download directory not found");
        return;
      }

      String destinationDirectory = "${downloadDirectory.path}/$videoFileName";

      if (!await Directory(downloadDirectory.path).exists()) {
        await Directory(downloadDirectory.path).create(recursive: true);
      }

      await videoFile.copy(destinationDirectory);
      print("VIDEO DOWNLOAD SUCCESS");
    } catch (e, stacktrace) {
      //print("EXCEPTION: $e");
      //print("StackTrace: $stacktrace");
      print("Failed to download video");
    }
  }

  Future<void> shareVideo(String projectName) async {
    // Retrieve the video file path
    final directory = TimelapseStore.getProjectDir(projectName);
    final videoFile = File('${directory.path}/timelapse_video.mp4');

    if (await videoFile.exists()) {
      try {
        const platform = MethodChannel('com.example.chronolapse/share');
        await platform.invokeMethod('shareVideo', {'videoPath': videoFile.path});
      } on PlatformException catch (e) {
        print("Failed to share video: $e");
      }
    } else {
      print("Video file not found!");
    }
  }

  Future<void> downloadAllFrames(String projectName) async {

    Directory projectDirectory = TimelapseStore.getProjectDir(projectName);
    Directory framesDirectory = Directory(projectDirectory.path + '/frames');

    if (!await framesDirectory.exists()) {
      print("Frames directory doesn't exist");
      return;
    }

    Directory? downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory == null) {
      print("Can't access downloads directory");
      return;
    }

    // create folder to hold all frames
    Directory projectFramesDirectory = Directory(path.join(downloadsDirectory.path, projectName));
    if (!await projectFramesDirectory.exists()) {
      await projectFramesDirectory.create(recursive: true);
    }

    List<FileSystemEntity> frames = framesDirectory.listSync();

    for (FileSystemEntity frame in frames) {
      if (frame is File) {
        try {

          String fileName = path.basename(frame.path);
          String destinationPath = path.join(projectFramesDirectory.path, fileName);
          await frame.copy(destinationPath);

          print("Frame saved: " + destinationPath);
        } catch (e) {
          print("Error saving frame: " + frame.path);
          print("Error: $e");
        }
      }
    }

    print("All frames have been saved to: " + projectFramesDirectory.path);
  }
}