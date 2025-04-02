import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/main.dart';
import 'package:chronolapse/ui/models/pending_frame.dart';
import 'package:chronolapse/ui/pages/photo_preview_page.dart';
import 'package:chronolapse/ui/shared/feature_points_editor.dart';
import 'package:chronolapse/ui/shared/project_navigation_rail.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:chronolapse/util/util.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../backend/settings_storage/settings_options.dart';
import '../shared/settings_cog.dart';

const String cameraCacheDirectory = "camera";

class PhotoTakingPage extends StatefulWidget {
  final String _projectName;

  const PhotoTakingPage(this._projectName, {super.key});

  @override
  State<StatefulWidget> createState() {
    return PhotoTakingPageState();
  }
}

class PhotoTakingPageState extends State<PhotoTakingPage>
    with WidgetsBindingObserver, RouteAware {
  static const ResolutionPreset _resolutionPreset = ResolutionPreset.max;
  static const Duration _pictureTakingTimeoutDuration = Duration(seconds: 30);
  static double _referenceOverlayOpacity = 0.33;

  late CameraController _cameraController;

  // Reference frame information
  late Image _referenceFrameImage;
  late GlobalKey _referenceFrameImageKey;
  late (int, int) _referenceFrameDimensions;
  late List<FeaturePoint> _referenceFrameFeaturePoints;
  bool _hasReferenceFrame = false;

  @override
  void initState() {
    super.initState();

    // Create camera controller using first available camera
    _cameraController = CameraController(cameras.first, _resolutionPreset);

    _referenceOverlayOpacity =
        referenceOverlayOpacity.getValue().toDouble() / 100;

    _initializeCameraController();

    // Get reference frame
    _getReferenceFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _referenceOverlayOpacity =
        referenceOverlayOpacity.getValue().toDouble() / 100;
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: <Widget>[settingsCog(context, widget._projectName)],
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_upward))),
      body: Stack(children: [
        // Camera preview
        Center(
            child:
                _createReferenceFrameOverlay(CameraPreview(_cameraController))),
        // Take photo button
        Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(25.0),
            child: Stack(children: [
              Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5)),
                  child: Center(
                      child: ElevatedButton(
                    key: photoTakingShutterButtonKey,
                    onPressed: () {
                      _onShutterButtonPressed();
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
      bottomNavigationBar: SizedBox(
        height: 100,
        child: RotatedBox(
            quarterTurns: 1,
            child: ProjectNavigationRail(widget._projectName, 0)),
      ),
    );
  }

  Future<void> _initializeCameraController() async {
    // Initialize camera controller
    try {
      await _cameraController.initialize();
    } on CameraException catch (e) {
      // TODO: work out how to best report error
      print("Error initializing camera controller: ${e.toString()}");
    }

    // Notify state change
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getReferenceFrame() async {
    final project = await TimelapseStore.getProject(widget._projectName);

    if (project.data.metaData.frames.isEmpty) return;

    final referenceFrame = await TimelapseFrame.fromExisting(
        project.projectName(), project.data.metaData.frames[0]);

    _referenceFrameImageKey = GlobalKey();
    _referenceFrameImage =
        Image.file(referenceFrame.getFramePng(), key: _referenceFrameImageKey);
    _referenceFrameFeaturePoints = referenceFrame.data.featurePoints;
    _referenceFrameDimensions =
        await getImageDimensions(referenceFrame.getFramePng().path);
    _hasReferenceFrame = true;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onShutterButtonPressed() async {
    if (!_cameraController.value.isInitialized) {
      print("Error: _takePhoto called before camera controller is initialized");
      return;
    }

    try {
      // Take picture
      await _cameraController.pausePreview();

      _takePictureUsingImageStream(_cameraController, (imagePath) async {
        print("Took picture $imagePath");

        await _cameraController.resumePreview();

        // Transition to PicturePreviewPage
        final project = await TimelapseStore.getProject(widget._projectName);
        final frameIndex = project.data.metaData.frames.length;

        final pendingFrame = PendingFrame(
            projectName: widget._projectName,
            frameIndex: frameIndex,
            temporaryImagePath: imagePath);

        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PhotoPreviewPage(pendingFrame)));
        }
      }).timeout(_pictureTakingTimeoutDuration);
    } on TimeoutException catch (_) {
      print("Timed out taking picture");
    } on Exception catch (e) {
      print("Error taking picture: ${e.toString()}");
    } finally {
      await _cameraController.resumePreview();
    }
  }

  Widget _createReferenceFrameOverlay(Widget background) {
    if (!_hasReferenceFrame) return background;

    return Stack(children: [
      background,
      RotatedBox(
          quarterTurns: 1,
          child: FeaturePointsEditor(
            featurePoints: _referenceFrameFeaturePoints,
            backgroundImage: Opacity(
                opacity: _referenceOverlayOpacity, child: _referenceFrameImage),
            backgroundImageKey: _referenceFrameImageKey,
            backgroundImageDimensions: _referenceFrameDimensions,
            allowDragging: false,
          )),
    ]);
  }

  // Workaround for issue with CameraController.takePicture()
  // `onImageTaken` is called with the path to the taken image
  // https://github.com/flutter/flutter/issues/126125
  // https://github.com/flutter/flutter/issues/126125#issuecomment-1986727724
  static Future<void> _takePictureUsingImageStream(
      CameraController cameraController,
      void Function(String) onImageTaken) async {
    if (cameraController.value.isStreamingImages) {
      await cameraController.stopImageStream();
    }
    await cameraController.startImageStream((cameraImage) async {
      await cameraController.stopImageStream();

      // Decode image
      final decodedImage = switch (cameraImage.format.group) {
        ImageFormatGroup.nv21 => _nv21ToRgb(cameraImage),
        ImageFormatGroup.yuv420 => _yuv420ToRgb(cameraImage),
        _ => img.decodeImage(cameraImage.planes[0].bytes),
      }!;

      // Rotate image
      final rotatedImage = img.copyRotate(decodedImage,
          angle: (cameraController.description.sensorOrientation + 270) % 360);

      // Save image to temporary file
      final data = img.encodePng(rotatedImage).toList();

      final temporaryDir = await getApplicationCacheDirectory();
      final cameraDir = Directory("${temporaryDir.path}/$cameraCacheDirectory");

      if (!await cameraDir.exists()) {
        await cameraDir.create();
      }

      final imagePath = "${cameraDir.path}/${DateTime.now().hashCode}.png";

      final file = File(imagePath);
      await file.writeAsBytes(data, flush: true);

      onImageTaken(imagePath);
    });
  }

  // The following two functions are written by GitHub user SunFoxx
  // https://github.com/flutter/flutter/issues/126125#issuecomment-1986727724

  static img.Image _yuv420ToRgb(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    var imgRgb = img.Image(width: width, height: height);

    final planes = image.planes;
    final int uvRowStride = planes[1].bytesPerRow;
    final int uvPixelStride = planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvRowStride * (y ~/ 2) + (x ~/ 2) * uvPixelStride;
        final int index = y * width + x;

        final yp = planes[0].bytes[index];
        final up = planes[1].bytes[uvIndex];
        final vp = planes[2].bytes[uvIndex];

        // Convert YUV to RGB
        var r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        var g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        var b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        imgRgb.setPixelRgb(x, y, r, g, b);
      }
    }

    return imgRgb;
  }

  // coverage:ignore-start
  static img.Image _nv21ToRgb(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    var imgRgb = img.Image(width: width, height: height);

    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List vuPlane = image.planes[1].bytes;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int vuIndex = (y ~/ 2) * width + (x ~/ 2) * 2;

        final int yp = yPlane[yIndex];
        final int vp = vuPlane[vuIndex];
        final int up = vuPlane[vuIndex + 1];

        var r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        var g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        var b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        imgRgb.setPixelRgb(x, y, r, g, b);
      }
    }

    return imgRgb;
  }
  // coverage:ignore-end
}

/// Deletes any remaining temporary images from photo taking
Future<void> cleanUpTakenImages() async {
  final temporaryDir = await getApplicationCacheDirectory();
  final cameraDir = Directory("${temporaryDir.path}/$cameraCacheDirectory");
  if (!await cameraDir.exists()) {
    return;
  }

  for (final entry in await cameraDir.list().toList()) {
    entry.delete(recursive: true);
  }
}
