
import 'dart:typed_data';

import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/native_methods/test_function.dart';
import 'package:chronolapse/ui/example_page_one.dart';
import 'package:chronolapse/ui/models/project_card.dart';
import 'package:flutter/material.dart';

String? currentProject = "sampleProject";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Initialising SettingsStore");
  await SettingsStore.initialise();
  print("Intialising TimelapseStore");
  await TimelapseStore.initialise();

  await TimelapseStore.deleteAllProjects();
  const projectName = "testProject";
  await TimelapseStore.createProject(projectName);
  final frame = TimelapseFrame.createNew(projectName);
  await frame.saveFrameFromPngBytes(Uint8List(12));

  print("Test: ${await testFunction(5)}");


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // Color blackColour = const Color(0xff08070B);
  // Color greyColour = const Color(0xff131316);
  // Color whiteColour = const Color(0xffCCCCCC);
  // Color blueColour1 = const Color(0xff11373B);
  // Color blueColour2 = const Color(0xff384547);
  // Color redColour = const Color(0xff3A0101);
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
        colorScheme: ColorScheme(
          primary: Color(0xff08070B),
          onPrimary: Color(0xffCCCCCC),
          secondary: Color(0xff11373B),
          onSecondary: Color(0xffCCCCCC),
          surface: Color(0xff131316),
          onSurface: Color(0xff384547),
          error: Color(0xff3A0101),
          onError: Color(0xffCCCCCC),
          brightness: Brightness.dark,
        ),

        useMaterial3: true,
      ),
      home: const ExamplePageOne("Title"),
      // home: const ScratchPage(),

    );
  }
}
