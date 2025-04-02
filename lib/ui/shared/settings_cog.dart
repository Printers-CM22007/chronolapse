import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:flutter/material.dart';

/// Settings cog IconButton linking to the `SettingsPage`
IconButton settingsCog(BuildContext context, String projectName,
    {bool enabled = true}) {
  return IconButton(
    icon: const Icon(Icons.settings),
    onPressed: enabled
        ? () {
            if (context.mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SettingsPage(projectName)));
            }
          }
        : null,
  );
}
