# Chronolapse

## Getting Started

- Install Dart
- Install Flutter
- Installing Flutter via vscode will automatically install the Dart SDK; https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
- Install Android Studio
- At some point when prompted go through the Android Studio setup wizard to get Android SDKs and Emulators
- Install the Flutter plugin in Android Studio

---

- Run `flutter doctor --verbose` to make sure you didn't do anything stupid

---

- Open the project in Android Studio
- To work on the Android native Kotlin/Java, open the `android` folder as a project (the same way you opened `chronolapse` - you can open both at once in separate windows)
- DO NOT CLICK ON ANY PROMPTS TO UPGRADE THE PROJECT / GRADLE / ETC.
- For some reason the IDE doesn't like me git pushing through the IDE so I commit/merge through the IDE and `git pull`/`git push` through the console
- You may need to modify your `android/local.properties` - mine looks like this:

```properties
sdk.dir=/home/robert/Android/Sdk
flutter.sdk=/home/robert/flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

---

- DM Robert if issues

## Commands

### Building an Apk
> Using an emulator / phone attached by USB is way easier for testing
```bash
flutter build apk --release
```

### Regenerating Icons
```bash
flutter pub run flutter_launcher_icons
```

> Note: You may need to comment out the following to get the command to work. Be sure to uncomment after command is run
```
  flutter:
    sdk: flutter
```

### Regenerating Splash Screen
```bash
flutter pub run flutter_native_splash:create
```

## Testing
### Unit Tests
Unit tests in `test` run without Android and can generate coverage reports:
```bash
flutter test --coverage
```
The coverage report needs to be converted to html with this command from the `lcov` tool:
```bash
genhtml coverage/lcov.info -o coverage/html
```
The report can then be opened:
```bash
open coverage/html/index.html
```


As these tests run without Android, they cannot test native code (i.e. code in the `android` folder)

### Integration Tests
Integration tests in `integration_tests` run with Android and cannot generate coverage reports
however can run native code.
Start an emulator normally and run:
```
flutter run integration_test/[TEST TO RUN]
```

## Useful Links

[Material UI Components](https://flutter.github.io/samples/web/material_3_demo/) [Dart/Flutter Source Code](https://github.com/flutter/samples/tree/main/material_3_demo/lib)
    

[Documentation](http://github.com/Printers-CM22007/documentation/)