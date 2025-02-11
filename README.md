# Chronolapse

## Getting Started

- Install Dart
- Install Flutter
- Install Android Studio
- At some point when prompted go through the Android Studio setup wizard to get Android SDKs and Emulators
- Install the Flutter plugin in Android Studio

---

- Run `flutter doctor --verbose` to make sure you didn't do anything stupid

---

- Open the project in Android Studio
- To work on the Android native Kotlin/Java, open the `android` folder as a project (the same way you opened `chronolapse` - you can open both at once in separate windows)
- DO NOT CLICK ON ANY PROMPTS TO UPGRADE THE PROJECT / GRADLE / ETC.
- For some reason the IDE doesn't like me git pushing through the IDE so I commit/pull/merge through the IDE and `git push` through the console
- You may need to modify your `android/local.properties` - mine looks like this:

```
sdk.dir=/home/robert/Android/Sdk
flutter.sdk=/home/robert/flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```