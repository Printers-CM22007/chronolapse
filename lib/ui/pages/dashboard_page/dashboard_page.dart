import 'dart:io';

import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:chronolapse/ui/pages/project_edit_page.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:chronolapse/ui/shared/dashboard_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../models/project_card.dart';
import 'dashboard_icons.dart';

part 'project_card_list.dart';
part 'search_bar.dart';
part 'create_new_button.dart';
part 'import_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> with RouteAware {
  late List<ProjectCard> _projects;
  bool _projectsLoaded = false;
  String _projectsSearchString = "";
  String? _projectCreateError;

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

  Future<void> _loadProjects() async {
    _projects = await ProjectCard.getProjects();
    _projectsLoaded = true;

    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchFieldChanged(String value) {
    _projectsSearchString = value;
    setState(() {});
  }

  Future<String?> _onCompleteCreateProjectDialogue(String projectName) async {
    // create the project in the backend
    await TimelapseStore.createProject(projectName);

    // reload project list
    await _loadProjects();
    return null;
  }

  final TextEditingController _projectNameController = TextEditingController();

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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      body: Column(
        children: [
          _searchBar(),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_createNewButton(), _importButton()],
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
            child: _projectsLoaded && _projects.isEmpty
                ? const Text("No projects - click 'Create New' to get started")
                : _createProjectCardList(),
          ),
        ],
      ),
      bottomNavigationBar: const DashboardNavigationBar(0),
    );
  }
}
