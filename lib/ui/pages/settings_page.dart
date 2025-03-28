import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/settings_options.dart';
import 'package:chronolapse/ui/shared/dashboard_navigation_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String? _project;

  const SettingsPage(this._project, {super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final globalWidgets =
        availableGlobalSettings.map((e) => e.getWidget()).toList();
    final projectWidgets = widget._project == null
        ? <Widget>[]
        : availableProjectSettings
            .map(
                (e) => e.withProject(ProjectName(widget._project!)).getWidget())
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget._project == null
              ? "Settings"
              : "Settings - ${widget._project}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: projectWidgets + globalWidgets,
      ),
      bottomNavigationBar: const DashboardNavigationBar(1),
    );
  }
}
