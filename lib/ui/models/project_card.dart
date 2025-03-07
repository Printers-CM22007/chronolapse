import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:flutter/material.dart';

Color blackColour = const Color(0xff08070B);
Color greyColour = const Color(0xff131316);
Color whiteColour = const Color(0xffCCCCCC);
Color blueColour1 = const Color(0xff11373B);
Color blueColour2 = const Color(0xff384547);
Color redColour = const Color(0xff3A0101);

class ProjectCard {
  String projectName;
  String? previewPicturePath;
  String lastEdited;
  Color boxColor = blackColour;

  ProjectCard({
    required this.projectName,
    required this.previewPicturePath,
    required this.lastEdited,
  });

  static Future<List<ProjectCard>> getProjects() async {
    final projectNames = TimelapseStore.getProjectList();

    return projectNames.map((name) async {
      final project = await TimelapseStore.getProject(name);

      // Get path to first frame
      final firstFrameUuid = project.data.metaData.frames.firstOrNull;
      final firstFramePath = firstFrameUuid == null
          ? null
          : (await TimelapseFrame.fromExisting(name, firstFrameUuid))
              .getFramePng()
              .path;

      return ProjectCard(
          projectName: name,
          previewPicturePath: firstFramePath,
          lastEdited: "TODO");
    }).wait;
  }
}
