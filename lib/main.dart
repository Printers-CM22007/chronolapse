import 'package:chronolapse/backend/settings_storage/settings_storage.dart';
import 'package:chronolapse/backend/settings_storage/settings_storage_content.dart';
import 'package:chronolapse/native_methods/test_function.dart';
import 'package:chronolapse/ui/example_page_one.dart';
import 'package:flutter/material.dart';

String? currentProject = "sampleProject";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedStorage.initialise();

  // Setters and getters accessible and intellisensed
  await exampleToggleSetting.setValue(true);
  print(exampleToggleSetting.getValue());
  await exampleToggleSetting.setValue(false);
  print(exampleToggleSetting.getValue());

  // Projects must be specified for non-global settings
  // [X] await exampleToggleSettingTwo.setValue(true);
  await exampleToggleSettingTwo.withProject("sampleProject").setValue(true);
  await exampleToggleSettingTwo.withCurrentProject().setValue(true);

  // Setters and getters inaccessible through widget lists:
  // [X] await availableGlobalSettings[1].getValue();
  // Widget only available
  availableGlobalSettings[1].getWidget();

  // Similarly with widgets that require projects
  availableProjectSettings[1].withProject("sampleProject").getWidget();
  availableProjectSettings[1].withCurrentProject().getWidget();

  print("Test: ${await testFunction(5)}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamplePageOne(title: 'Flutter Demo Home Page'),
      // home: const ScratchPage(),
    );
  }
}
