import 'package:camera/camera.dart';
import 'package:chronolapse/backend/settings_storage/settings_storage.dart';
import 'package:chronolapse/native_methods/test_function.dart';
import 'package:chronolapse/ui/example_page_one.dart';
import 'package:flutter/material.dart';

String? currentProject = "sampleProject";

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedStorage.initialise();

  print("Test: ${await testFunction(5)}");

  // List available cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // TODO: work out how to best report error
    debugPrint("Error listing available cameras: ${e.toString()}");
  }

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
      home: const ExamplePageOne("Title"),
      // home: const ScratchPage(),
    );
  }
}
