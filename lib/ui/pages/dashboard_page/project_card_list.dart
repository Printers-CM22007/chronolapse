part of 'dashboard_page.dart';

extension ProjectCardList on DashboardPageState {
  void _onPressProjectThumbnail(String projectName) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PhotoTakingPage(projectName)));
  }

  void _onPressProjectEdit(String projectName) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProjectEditPage(projectName)));
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
                              width: constraints.maxWidth * 0.4,
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
                            Container(
                              //color: Colors.yellow,
                              width: constraints.maxWidth * 0.4,
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
                                        Size(100, 80)),
                                    backgroundColor: WidgetStatePropertyAll(
                                        Theme.of(context)
                                            .colorScheme
                                            .inverseSurface),
                                  ),
                                  alignmentOffset: const Offset(-60, -100),
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
                                    SizedBox(
                                      width: 100,
                                      height: 30,
                                      child: MenuItemButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface),
                                          fixedSize:
                                              const WidgetStatePropertyAll(
                                                  Size(100, 40)),
                                        ),
                                        onPressed: () => {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExportPage(
                                                          project.projectName)))
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              DashboardPageIcons.export,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onInverseSurface,
                                            ),
                                            Text(
                                              "Export",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onInverseSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      height: 30,
                                      child: MenuItemButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface),
                                          fixedSize:
                                              const WidgetStatePropertyAll(
                                                  Size(100, 40)),
                                        ),
                                        onPressed: () async {
                                          await TimelapseStore.deleteProject(
                                              project.projectName);
                                          await _loadProjects();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              DashboardPageIcons.bin,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onInverseSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ));
          },
        ));
  }
}
