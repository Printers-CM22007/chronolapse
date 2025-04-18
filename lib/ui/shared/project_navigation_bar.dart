import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:chronolapse/ui/pages/project_editor_page.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:flutter/material.dart';

/// Navigation bar for photo taking, project editing, and exporting
class ProjectNavigationBar extends StatelessWidget {
  final String _projectName;
  final int _selectedIndex;
  final bool disabled;

  const ProjectNavigationBar(this._projectName, this._selectedIndex,
      {this.disabled = false, super.key});

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
            if (index == _selectedIndex) {
              return;
            }
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => PhotoTakingPage(_projectName)));
                break;

              case 1:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => ProjectEditorPage(_projectName)));
                break;

              case 2:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => ExportPage(_projectName)));
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(
                Icons.camera_alt,
              ),
              label: "Take photo",
              enabled: !disabled,
              key: projectNavigationBarPhotoTakingKey,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.edit,
              ),
              label: "Edit frames",
              enabled: !disabled,
              key: projectNavigationBarEditKey,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.arrow_upward,
              ),
              label: "Export",
              enabled: !disabled,
              key: projectNavigationBarExportKey,
            ),
          ]),
    );
  }
}
