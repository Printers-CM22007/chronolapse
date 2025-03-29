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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Cleaning up cache");
  await cleanupGeneratedVideo();
  await cleanUpTakenImages();
  print("Initialising SettingsStore");
  await SettingsStore.initialise();
  print("Initialising TimelapseStore");
  await TimelapseStore.initialise();
  print("Initialising NotificationService");
  notificationService = NotificationService();
  await notificationService.initialise();

  // List available cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // TODO: work out how to best report error
    debugPrint("Error listing available cameras: ${e.toString()}");
  }

  runApp(const AppRoot(DashboardPage()));
}

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
