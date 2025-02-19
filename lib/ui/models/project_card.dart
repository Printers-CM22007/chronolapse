import 'package:flutter/material.dart';

Color blackColour = const Color(0xff08070B);
Color greyColour = const Color(0xff131316);
Color whiteColour = const Color(0xffCCCCCC);
Color blueColour1 = const Color(0xff11373B);
Color blueColour2 = const Color(0xff384547);
Color redColour = const Color(0xff3A0101);

class ProjectCard {
  String projectName;
  String previewPicturePath;
  Color boxColor = blackColour;

  ProjectCard({
    required this.projectName,
    required this.previewPicturePath,
  });

  static List<ProjectCard> getProjects() {
    List<ProjectCard> projects = [];

    // Get projects here from the backend

    //These are filler projects
    projects.add(
      ProjectCard(
        projectName: "MyLittlePony",
        previewPicturePath: "assets/images/pretty_filler_image.png"
      )
    );

    projects.add(
        ProjectCard(
            projectName: "MyBigPony",
            previewPicturePath: "assets/images/pretty_filler_image.png"
        )
    );

    return projects;
  }
}