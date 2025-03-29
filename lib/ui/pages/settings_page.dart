import 'package:chronolapse/backend/settings_storage/project_requirements.dart';
import 'package:chronolapse/backend/settings_storage/setting_types/project_setting.dart';
import 'package:chronolapse/backend/settings_storage/settings_options.dart';
import 'package:chronolapse/ui/shared/dashboard_navigation_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String? _project;
  final List<WidgetSettingGlobal>? _globalSettings;
  final List<WidgetSettingRequiresProject>? _projectSettings;

  const SettingsPage(this._project,
      {globalSettings, projectSettings, super.key})
      : _globalSettings = globalSettings,
        _projectSettings = projectSettings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final currentProjectWidgets =
        widget._projectSettings ?? availableProjectSettings;
    final currentGlobalWidgets =
        widget._globalSettings ?? availableGlobalSettings;

    final globalWidgets =
        currentGlobalWidgets.map((e) => e.getWidget()).toList();
    final projectWidgets = widget._project == null
        ? <Widget>[]
        : currentProjectWidgets
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
        children: projectWidgets +
            (projectWidgets.isEmpty
                ? []
                : [
                    const DividerNoSetting()
                        .getWidget(const ProjectName.global())
                  ]) +
            globalWidgets,
      ),
      bottomNavigationBar: const DashboardNavigationBar(1),
    );
  }
}
