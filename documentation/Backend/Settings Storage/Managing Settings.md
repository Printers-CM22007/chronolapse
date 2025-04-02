[Back](Settings%20Storage.md)

# Managing Settings

All of the following methods require `SharedPreferences.initialise()` to have been called and awaited

To delete ==***all***== settings:
```dart
await SharedStorage.deleteAllSettings();
```

To delete all global settings:
```dart
await SharedStorage.deleteAllGlobalSettings();
```

To delete all project settings:
```dart
await SharedStorage.deleteAllProjectSettings("projectName");
```
