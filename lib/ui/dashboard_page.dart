import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/export_page.dart';
import 'package:chronolapse/ui/models/project_card.dart';
import 'package:chronolapse/ui/shared/dashboard_navigation_bar.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class DashboardPageIcons {
  DashboardPageIcons._();

  static const fontFamily = 'icomoon';

  static const IconData search = IconData(0xe986, fontFamily: fontFamily);

  static const IconData edit = IconData(0xe905, fontFamily: fontFamily);

  static const IconData projects = IconData(0xe920, fontFamily: fontFamily);

  static const IconData notifications =
      IconData(0xe951, fontFamily: fontFamily);

  static const IconData export = IconData(0xe968, fontFamily: fontFamily);

  static const IconData settings = IconData(0xe994, fontFamily: fontFamily);

  static const IconData bin = IconData(0xe9ac, fontFamily: fontFamily);

  static const IconData import = IconData(0xe9c5, fontFamily: fontFamily);

  static const IconData add = IconData(0xea0a, fontFamily: fontFamily);

  static const IconData dots = IconData(0xeaa3, fontFamily: fontFamily);
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  late List<ProjectCard> _projects;
  bool _projectsLoaded = false;
  String _projectsSearchString = "";

  @override
  void initState() {
    super.initState();

    _loadProjects();
  }

  @override
  void didChangeDependencies() {
    // (benny) Example called routeObserver.subscribe() in this function rather than initState, I don't know why
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when this page is returned to via the back button
    // In this situation we need to reload the projects in case a new project has
    // been created
    super.didPopNext();
    _loadProjects();
  }

  void _loadProjects() async {
    _projects = await ProjectCard.getProjects();
    _projectsLoaded = true;

    if (mounted) {
      setState(() {});
    }
  }

  List<ProjectCard> _getFilteredProjects() {
    assert(_projectsLoaded);

    return _projects
        .where((project) => project.projectName
            .toLowerCase()
            .contains(_projectsSearchString.toLowerCase()))
        .toList();
  }

  void _onSearchFieldChanged(String value) {
    _projectsSearchString = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.

        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(

          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),

        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white,), // Settings cog icon
            onPressed: () {

            },
          ),
        ],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      body: Column(
        children: [
          searchBar(),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [createNewButton(), importButton()],
          ),
          const SizedBox(
            height: 15,
          ),
          Divider(
            thickness: 1.2,
            color: Theme.of(context).colorScheme.onPrimary,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: projectsContainer(),
          ),
          const SizedBox(
            height: 1,
          )
        ],
      ),

      bottomNavigationBar: const DashboardNavigationBar(0),

    );
  }

  Container importButton() {
    return Container(
      width: 120,
      padding: const EdgeInsets.only(right: 25),
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              DashboardPageIcons.import,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            Text(
              "Import",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            )
          ],
        ),
      ),
    );
  }

  SizedBox createNewButton() {
    return SizedBox(
      width: 150,
      child: Padding(
        padding: const EdgeInsets.only(left: 18),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                DashboardPageIcons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              Text(
                "Create New",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget projectsContainer() {
    if (!_projectsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final projects = _getFilteredProjects();

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
            return Container(
                height: 300,
                decoration: BoxDecoration(
                    color: projects[index].boxColor,
                    borderRadius: BorderRadius.circular(18)),
                child: LayoutBuilder(
                  builder: (BuildContext bContext, BoxConstraints constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.025,
                        ),
                        SizedBox(
                          width: constraints.maxWidth * 0.9,
                          height: constraints.maxHeight * 0.65,
                          child: projects[index].previewPicturePath != null
                              ? Image.asset(projects[index].previewPicturePath!)
                              : const Icon(Icons.image),
                        ),
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
                                projects[index].projectName,
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
                                "Last edited ${projects[index].lastEdited} ago",
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
                                    //Open the project to be edited here
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
                                                          projects[
                                                                  index]
                                                              .projectName)))
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
                                            onPressed: () {
                                              //Add Export Functionality here
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Icon(
                                                  DashboardPageIcons.export,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface),
                                          fixedSize:
                                              const WidgetStatePropertyAll(
                                                  Size(100, 40)),

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
                                                          .onPrimary),
                                              fixedSize:
                                                  const WidgetStatePropertyAll(
                                                      Size(100, 40)),
                                            ),

                                            Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onInverseSurface,
                                              ),

                                            ),
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
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

  Container searchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        onChanged: _onSearchFieldChanged,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        cursorColor: Theme.of(context).colorScheme.onPrimary,
        decoration: InputDecoration(
            filled: true,
            fillColor: blackColour,
            hintText: "Search Project",
            hintStyle:
                TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            hoverColor: Theme.of(context).colorScheme.onPrimary,
            prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  DashboardPageIcons.search,
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none)),
      ),
    );
  }
}
