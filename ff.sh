echo Generating Code
flutter pub run build_runner build

echo Running Dart Fix
dart fix --apply

echo Running Dart Format
dart format .