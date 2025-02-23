import 'package:camera/camera.dart';
import 'package:chronolapse/main.dart';
import 'package:flutter/material.dart';

class CameraTestPage extends StatefulWidget {
  const CameraTestPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CameraTestPageState();
  }
}

class _CameraTestPageState extends State<CameraTestPage>
    with WidgetsBindingObserver {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCameraController();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Camera test"),
      ),
      body: Stack(children: [
        Center(child: CameraPreview(_cameraController)),
        Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
              onPressed: () {
                _takePhoto();
              },
              label: const Text("Take picture"),
              icon: const Icon(Icons.camera),
            ))
      ]),
    );
  }

  Future<void> _initializeCameraController() async {
    try {
      _cameraController = CameraController(cameras.first, ResolutionPreset.max,
          enableAudio: false);
      await _cameraController.initialize();

      debugPrint("Successfully initialized camera controller");
    } on CameraException catch (e) {
      debugPrint("Failed to initialize camera controller: ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _takePhoto() async {
    debugPrint("_takePhoto called");

    if (!_cameraController.value.isInitialized) {
      debugPrint("_takePhoto called before _cameraController is initialized");
      return;
    }

    if (_cameraController.value.isTakingPicture) {
      debugPrint("Already taking picture");
      return;
    }

    try {
      // Apparently needed (not documented, but doesn't work without)
      await _cameraController.pausePreview();

      final imageFile = await _cameraController
          .takePicture()
          .timeout(const Duration(seconds: 20));

      debugPrint("Captured photo ${imageFile.path}");
    } catch (e) {
      debugPrint("Failed to capture photo: ${e.toString()}");
    } finally {
      _cameraController.resumePreview();
    }
  }
}
