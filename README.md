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

## Installing Dependencies for OpenCV

### Windows

- You'll need to have dartcv.dll somewhere in your path for OpenCV to work.
- Either you can download a precompiled one I made here:
https://drive.google.com/file/d/1DbJWUd8MjKP7tKTwIl7uPLqDBiW4GXYT/view?usp=sharing

- Or compile the library yourself (you'll need a c compiler and cmake):
https://github.com/rainyl/dartcv

- Create a folder somewhere e.g C:/dev/dartcv and put dartcv.dll in there
- Go to edit environment variables and add the folder to path

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

### Regenerate JSON Code
```bash
flutter pub run build_runner build
```

## Testing

To run all tests, merge their coverage reports, then show them run
```bash
python test.py
```

If you want to use a specific shell to run commands, e.g. fish, run
```
python test.py fish
```

To run an individual test run
```bash
flutter test [path to test] --coverage
```

... then to view the coverage report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Editing the presentation
### Downloading fonts
There is a file called "computer-modern" which contains all of the fonts used in the presentation in the repository (somewhere, edit this)

Please download this.

#### Windows:
You can open the zip and download them by:
Editing the BAT file attached to change the directory to a folder containing the extracted fonts

Opening the fonts section in settings to drag and drop the selected fonts.

#### Linux or Mac
Good luck soldier, idk.

## Useful Links

[Material UI Components](https://flutter.github.io/samples/web/material_3_demo/) [Dart/Flutter Source Code](https://github.com/flutter/samples/tree/main/material_3_demo/lib)
    

[Documentation](http://github.com/Printers-CM22007/documentation/)
