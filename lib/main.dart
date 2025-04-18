import 'package:camera/camera.dart';
import 'package:chronolapse/backend/notification_service.dart';
import 'package:chronolapse/backend/settings_storage/settings_store.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/backend/video_generator/video_generator.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Used by DashboardPage to reload projects when it is returned to
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver();

late List<CameraDescription> cameras;

late NotificationService notificationService;

const landscapePhotos = true;

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Cleaning up cache");
  await cleanupGeneratedVideo();
  await cleanUpTakenImages();
  print("Initialising SettingsStore");
  await SettingsStore.initialise();
  print("Initialising TimelapseStore");
  await TimelapseStore.initialise();
  print("Initialising NotificationService");
  await NotificationService.initialise();

  // List available cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // Just-in-case code, should never run
    debugPrint(
        "Error listing available cameras: ${e.toString()}"); // coverage:ignore-line
  }
}

// Main function to run app
// coverage:ignore-start
void main() async {
  await setup();
  runApp(const AppRoot(DashboardPage()));
}
// coverage:ignore-end

class AppRoot extends StatelessWidget {
  final Widget _homePage;

  const AppRoot(this._homePage, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Chronolapse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xff3e3655),
          onPrimary: Color(0xffCCCCCC),
          secondary: Color(0xff0a616a),
          onSecondary: Color(0xffCCCCCC),
          surface: Color(0xff131316),
          onSurface: Color(0xffaacfd5),
          error: Color(0xff811d1d),
          onError: Color(0xffCCCCCC),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // home: const PhotoTakingPage("sampleProject"),
      home: _homePage,
      navigatorObservers: [routeObserver],
    );
  }
}
