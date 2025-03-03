import 'package:chronolapse/ui/models/project_card.dart';
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

class _DashboardPageState extends State<DashboardPage> {
  List<ProjectCard> projects = [];
  void _getProjects() {
    projects = ProjectCard.getProjects();
  }

  @override
  Widget build(BuildContext context) {
    _getProjects();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.

        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          "Project Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        ],
      ),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  Container bottomNavBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          // borderRadius: BorderRadius.only(
          //   topLeft: Radius.circular(35),
          //   topRight: Radius.circular(35)
          // ),
          boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 1)]),
      child: NavigationBar(
          shadowColor: Theme.of(context).colorScheme.onPrimary,
          height: 60,
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          selectedIndex: 0,
          indicatorColor: Theme.of(context).colorScheme.surface,
          // Commented out because this parameter doesn't exist - Robert
          // I think it does since it does make a change for me for the labels - Kaan
          labelTextStyle: WidgetStatePropertyAll(TextStyle(
              color: Theme.of(context).colorScheme.onPrimary
          )),
          //onDestinationSelected: (index) =>   ,
          destinations: [
            NavigationDestination(
                icon: Icon(
                  DashboardPageIcons.projects,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: "Projects"),
            NavigationDestination(
                icon: Icon(
                  DashboardPageIcons.settings,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: "Settings")
          ]),
    );
  }

  Container importButton() {
    return Container(
      width: 120,
      padding: const EdgeInsets.only(right: 25),
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onSurface),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              DashboardPageIcons.import,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            Text(
              "Import",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
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

  Container projectsContainer() {
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
                          child:
                              Image.asset(projects[index].previewPicturePath),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: (){},
                                      icon: Icon(DashboardPageIcons.settings, color: Theme.of(context).colorScheme.onPrimary,)),
                                  MenuAnchor(
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
                                                .onPrimary),
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
                                                .onPrimary,
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
                                                          .onPrimary),
                                              fixedSize:
                                                  const WidgetStatePropertyAll(
                                                      Size(100, 40)),
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
                                                      .primary,
                                                ),
                                                Text(
                                                  "Export",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
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
                                                          .onPrimary),
                                              fixedSize:
                                                  const WidgetStatePropertyAll(
                                                      Size(100, 40)),
                                            ),
                                            onPressed: () {
                                              //Add delete functionality here
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
                                                        .primary,
                                                  ),
                                                ),
                                              ],
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
