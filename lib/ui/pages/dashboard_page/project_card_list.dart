part of 'dashboard_page.dart';

enum CardOptions { settings, export, delete }

extension ProjectCardList on DashboardPageState {
  void _onPressProjectThumbnail(String projectName) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PhotoTakingPage(projectName)));
  }

  void _onPressProjectEdit(String projectName) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProjectEditorPage(projectName)));
  }

  List<ProjectCard> _getFilteredSortedProjects() {
    assert(_projectsLoaded);

    final filtered = _projects
        .where((project) => project.projectName
            .toLowerCase()
            .contains(_projectsSearchString.toLowerCase()))
        .toList();

    filtered.sort((cardA, cardB) {
      return cardB.lastEdited - cardA.lastEdited;
    });

    return filtered;
  }

  Widget _createProjectCardList() {
    if (!_projectsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final projects = _getFilteredSortedProjects();

    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        //height: 445,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
            height: 10,
          ),
          scrollDirection: Axis.vertical,
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Container(
                height: 300,
                decoration: BoxDecoration(
                    color: project.boxColor,
                    borderRadius: BorderRadius.circular(18)),
                child: LayoutBuilder(
                  builder: (BuildContext bContext, BoxConstraints constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.025,
                        ),
                        InkWell(
                            onTap: () {
                              _onPressProjectThumbnail(project.projectName);
                            },
                            child: SizedBox(
                                width: constraints.maxWidth * 0.9,
                                height: constraints.maxHeight * 0.65,
                                child: project.previewPicturePath != null
                                    ? Image.file(
                                        File(project.previewPicturePath!))
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 80,
                                            ),
                                            Text("Tap to take photo")
                                          ]))),
                        SizedBox(
                          height: constraints.maxHeight * 0.025,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              //color: Colors.yellow,
                              width: constraints.maxWidth * 0.45,
                              height: constraints.maxHeight * 0.1,
                              padding: EdgeInsets.only(
                                  left: constraints.maxWidth * 0.1),
                              child: Text(
                                project.projectName,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              //color: Colors.yellow,
                              width: constraints.maxWidth * 0.5,
                              height: constraints.maxHeight * 0.1,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                project.lastEditedText,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: constraints.maxHeight * 0.025,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                //color: Colors.yellow,
                                width: constraints.maxWidth * 0.35,
                                height: constraints.maxHeight * 0.125,
                                padding: EdgeInsets.only(
                                    left: constraints.maxWidth * 0.1),
                                child: TextButton(
                                  onPressed: () {
                                    _onPressProjectEdit(project.projectName);
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        DashboardPageIcons.edit,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                      Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            _cardOptionDropdown(project)

/*
                            Container(
                              //color: Colors.yellow,
                              width: constraints.maxWidth * 0.5,
                              height: constraints.maxHeight * 0.1,
                              alignment: Alignment.centerRight,
                              child: MenuAnchor(
                                  style: MenuStyle(
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15))),
                                    //maximumSize: WidgetStatePropertyAll(Size.fromHeight(40)),
                                    fixedSize: const WidgetStatePropertyAll(
                                        Size(120, 106)),
                                    backgroundColor: WidgetStatePropertyAll(
                                        Theme.of(context)
                                            .colorScheme
                                            .inverseSurface),
                                  ),
                                  alignmentOffset: const Offset(-60, -130),
                                  builder: (_, MenuController controller,
                                      Widget? child) {
                                    return IconButton(
                                      onPressed: () {
                                        if (controller.isOpen) {
                                          controller.close();
                                        } else {
                                          controller.open();
                                        }
                                      },
                                      icon: Icon(
                                        DashboardPageIcons.dots,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                      ),
                                    );
                                  },
                                  menuChildren: <Widget>[
                                    _cardOptionsEntry(
                                        project,
                                        "Settings",
                                        Icon(
                                          DashboardPageIcons.settings,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onInverseSurface,
                                        ), () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsPage(
                                                      project.projectName)));
                                    }),
                                    _cardOptionsEntry(
                                        project,
                                        "Export",
                                        Icon(
                                          DashboardPageIcons.export,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onInverseSurface,
                                        ), () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => ExportPage(
                                                  project.projectName)));
                                    }),
                                    _cardOptionsEntry(
                                        project,
                                        "Delete",
                                        Icon(
                                          DashboardPageIcons.bin,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ), () async {
                                      await TimelapseStore.deleteProject(
                                          project.projectName);
                                      await _loadProjects();
                                    })
                                  ]),
                            ),
*/
                          ],
                        ),
                      ],
                    );
                  },
                ));
          },
        ));
  }

  void _deleteConfirmationPopup(ProjectCard project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Deleting '${project.projectName}'"),
          content: Text(
              "Are you sure you want to delete '${project.projectName}' last modified ${project.lastEditedText}"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            TextButton(
              key: dashboardConfirmDeleteKey,
              onPressed: () async {
                Navigator.of(context).pop();
                await TimelapseStore.deleteProject(project.projectName);
                await _loadProjects();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cardOptionDropdown(ProjectCard project) {
    return PopupMenuButton<CardOptions>(
      offset: const Offset(-10, -160),
      onSelected: (value) async {
        switch (value) {
          case CardOptions.settings:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingsPage(project.projectName)));
            break;
          case CardOptions.export:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ExportPage(project.projectName)));
            break;
          case CardOptions.delete:
            _deleteConfirmationPopup(project);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<CardOptions>(
            key: popupMenuSettingsIconKey,
            value: CardOptions.settings,
            child: Row(
              children: [
                Icon(DashboardPageIcons.settings),
                SizedBox(width: 8),
                Text('Settings'),
              ],
            ),
          ),
          const PopupMenuItem<CardOptions>(
            value: CardOptions.export,
            child: Row(
              children: [
                Icon(DashboardPageIcons.export),
                SizedBox(width: 8),
                Text('Export'),
              ],
            ),
          ),
          PopupMenuItem<CardOptions>(
            value: CardOptions.delete,
            child: Row(
              children: [
                Icon(
                  DashboardPageIcons.bin,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Text('Delete'),
              ],
            ),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert),
    );
  }

  /*Widget _cardOptionsEntry(
      ProjectCard project, String text, Icon icon, VoidCallback onClick) {
    return SizedBox(
      width: 100,
      height: 30,
      child: MenuItemButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.inverseSurface),
          fixedSize: const WidgetStatePropertyAll(Size(100, 40)),
        ),
        onPressed: onClick,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon,
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }*/
}
