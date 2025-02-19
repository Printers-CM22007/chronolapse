import 'package:chronolapse/backend/settings_storage/settings_options.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String _project;

  const SettingsPage(this._project, {super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Settings - ${widget._project}"),
        ),
        body: ListView(
          children: availableProjectSettings
                  .map((e) => e.withProject(widget._project).getWidget())
                  .toList() +
              availableGlobalSettings.map((e) => e.getWidget()).toList(),
        ));
  }
}
