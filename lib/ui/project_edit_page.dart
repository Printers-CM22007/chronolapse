import 'package:chronolapse/ui/shared/project_navigation_bar.dart';
import 'package:flutter/material.dart';

class ProjectEditPage extends StatefulWidget {
  final String _projectName;

  const ProjectEditPage(this._projectName, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ProjectEditPageState();
  }
}

class ProjectEditPageState extends State<ProjectEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "Edit - ${widget._projectName}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
      bottomNavigationBar: ProjectNavigationBar(widget._projectName, 1),
    );
  }
}
