[Back](Settings%20Storage.md)

# Creating Settings

Settings can be created in `backend/settings_storage/settings_options.dart`.

Here are some examples:
```dart
// Global Settings  
const exampleToggleSetting = Global(ToggleSetting("exampleToggle", false));  
  
// Project Settings  
const exampleToggleSettingTwo =  
    RequiresProject(ToggleSetting("exampleToggleTwo", true));
```

>[!warning] 
>Only use alphanumeric characters in the settings key! (e.g. `"exampleToggle"`)

To have these appear in the settings menu, add them to the lists at the top of the files like so:

```dart
// List of global settings (as well as decorations) available in the settings  
// page  
List<WidgetSettingGlobal> availableGlobalSettings = [  
  const WidgetSettingGlobal(TitleNoSetting("Global Settings")),  
  exampleToggleSetting.asWidgetOnly(),  
  const WidgetSettingGlobal(DividerNoSetting()),  
];  
  
// List of project settings (as well as decorations) available in the settings  
// page  
List<WidgetSettingRequiresProject> availableProjectSettings = [  
  const WidgetSettingRequiresProject(TitleNoSetting("Project Settings")),  
  exampleToggleSettingTwo.asWidgetOnly(),  
  const WidgetSettingRequiresProject(DividerNoSetting()),  
];
```
> These lists require the widget-only version which hides the value setters and getters. This also allows the use widgets with no settings for formatting.

This creates a settings page like so:
![image](../../attachments/Pasted%20image%2020250220191551.png)