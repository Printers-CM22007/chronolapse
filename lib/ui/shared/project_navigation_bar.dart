import 'package:chronolapse/ui/export_page.dart';
import 'package:chronolapse/ui/photo_taking_page.dart';
import 'package:chronolapse/ui/project_edit_page.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:flutter/material.dart';

class ProjectNavigationBar extends StatelessWidget {
  final String _projectName;
  final int _selectedIndex;

  const ProjectNavigationBar(this._projectName, this._selectedIndex,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      child: NavigationBar(
          shadowColor: Theme.of(context).colorScheme.onInverseSurface,
          height: 60,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          selectedIndex: _selectedIndex,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => PhotoTakingPage(_projectName)));
                break;

              case 1:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => ProjectEditPage(_projectName)));
                break;

              case 2:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => ExportPage(_projectName)));
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Take photo",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Edit frames",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.arrow_upward,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Export",
            ),
          ]),
    );
  }
}
