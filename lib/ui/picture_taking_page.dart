import 'dart:async';

import 'package:camera/camera.dart';
import 'package:chronolapse/main.dart';
import 'package:flutter/material.dart';

class PictureTakingPage extends StatefulWidget {
  const PictureTakingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return PictureTakingPageState();
  }
}

class PictureTakingPageState extends State<PictureTakingPage>
    with WidgetsBindingObserver {
  static const ResolutionPreset _resolutionPreset = ResolutionPreset.max;
  static const Duration _pictureTakingTimeoutDuration = Duration(seconds: 30);

  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();

    // Create camera controller using first available camera
    _cameraController = CameraController(cameras.first, _resolutionPreset);

    _initializeCameraController();
  }

  @override
  void dispose() {
    _cameraController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Camera"),
      ),
      body: Stack(children: [
        // Camera preview
        Center(child: CameraPreview(_cameraController)),
        // Take photo button
        Container(
            alignment: Alignment.bottomCenter,
            child: Stack(children: [
              Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5)),
                  child: Center(
                      child: ElevatedButton(
                    onPressed: () {
                      _takePhoto();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      backgroundColor:
                          Colors.white.withAlpha(200), // Button color
                      elevation: 5,
                    ),
                    child:
                        const Icon(Icons.camera, color: Colors.white, size: 60),
                  )))
            ]))
      ]),
      backgroundColor: Colors.black,
    );
  }

  Future<void> _initializeCameraController() async {
    // Initialize camera controller
    try {
      await _cameraController.initialize();
    } on CameraException catch (e) {
      // TODO: work out how to best report error
      debugPrint("Error initializing camera controller: ${e.toString()}");
    }

    // Notify state change
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePhoto() async {
    if (!_cameraController.value.isInitialized) {
      debugPrint(
          "Error: _takePhoto called before camera controller is initialized");
      return;
    }

    try {
      await _cameraController.pausePreview();
      final imageFile = await _cameraController
          .takePicture()
          .timeout(_pictureTakingTimeoutDuration);

      debugPrint("Took picture ${imageFile.path}");
    } on CameraException catch (e) {
      debugPrint("Error taking picture: ${e.toString()}");
    } on TimeoutException catch (e) {
      debugPrint("Timed out taking picture");
    } finally {
      await _cameraController.resumePreview();
    }
  }
}
