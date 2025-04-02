import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:chronolapse/ui/pages/project_editor_page.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:flutter/material.dart';

/// Rotated version of `ProjectNavigationBar`
class ProjectNavigationRail extends StatelessWidget {
  final String _projectName;
  final int _selectedIndex;
  final bool disabled;

  const ProjectNavigationRail(this._projectName, this._selectedIndex,
      {this.disabled = false, super.key});

  @override
  Widget build(BuildContext context) {
    const itemPadding = 25.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      child: NavigationRail(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIndex: 2 - _selectedIndex,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelType: NavigationRailLabelType.all,
          groupAlignment: 0.5,
          onDestinationSelected: (index) {
            if (index == 2 - _selectedIndex) {
              return;
            }
            switch (index) {
              case 2:
                // Not going to be covered by testing as nav rail is only used
                // on photo-taking page, where this is inactive
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => PhotoTakingPage(_projectName)));
                break;

              case 1:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => ProjectEditorPage(_projectName)));
                break;

              case 0:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => ExportPage(_projectName)));
                break;
            }
          },
          destinations: const [
            NavigationRailDestination(
                icon: Icon(
                  Icons.arrow_upward,
                  key: projectNavigationBarExportKey,
                ),
                label: Text("Export", textAlign: TextAlign.center),
                padding: EdgeInsets.fromLTRB(0, itemPadding, 0, itemPadding)),
            NavigationRailDestination(
                icon: Icon(
                  Icons.edit,
                  key: projectNavigationBarEditKey,
                ),
                label: Text("Edit frames", textAlign: TextAlign.center),
                padding: EdgeInsets.fromLTRB(0, itemPadding, 0, itemPadding)),
            NavigationRailDestination(
                icon: Icon(
                  Icons.camera_alt,
                  key: projectNavigationBarPhotoTakingKey,
                ),
                label: Text("Take photo", textAlign: TextAlign.center),
                padding: EdgeInsets.fromLTRB(0, itemPadding, 0, itemPadding)),
          ]),
    );
  }
}
