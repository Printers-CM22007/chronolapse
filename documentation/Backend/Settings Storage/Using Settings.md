[Back](Settings%20Storage.md)

# Using Settings

Once a setting is defined (see [[Creating Settings](Creating%20Settings.md)]) you can get its value:
```dart
exampleToggleSetting.getValue();
```
Or set its value
```dart
await exampleToggleSetting.setValue(true);
```

For non-global settings you can do the same like so:
```dart
exampleToggleSettingTwo.withProject("sampleProject").getValue(); 

await exampleToggleSettingTwo.withProject("sampleProject").setValue(true);  
```

Or more conveniently if the `currentProject` is set in `main.dart`:
```dart
exampleToggleSettingTwo.withCurrentProject().getValue(); 

await exampleToggleSettingTwo.withCurrentProject().setValue(true);
```
> You are responsible for ensuring `currentProject` is sent. A runtime error will be thrown if it is `null`


