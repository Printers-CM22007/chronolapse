// import 'dart:ui';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_alignment.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/pages/project_editor_page.dart';
import 'package:chronolapse/ui/shared/feature_points_editor.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:chronolapse/util/util.dart';
import 'package:flutter/material.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../backend/timelapse_storage/frame/timelapse_frame.dart';

class FrameEditor extends StatefulWidget {
  final String _projectName;
  final String _uuid;

  const FrameEditor(this._projectName, this._uuid, {super.key});

  @override
  FrameEditorState createState() => FrameEditorState();
}

class FrameEditorState extends State<FrameEditor>
    with SingleTickerProviderStateMixin {
  static const String _pageTitle = 'Edit frame';

  double opacity = 0.3;
  double brightness = 0.0;
  double contrast = 1.0;
  double saturation = 1.0;
  double balanceFactor = 0.0;

  bool _useManualAlignment = false;
  bool _isFirstFrame = false;

  int? selectedMarkerIndex;
  bool showMarkers = true;
  bool isDragging = false;

  final GlobalKey _boundaryKey = GlobalKey();

  late TabController tabController;

  late Image _frameImage;
  late String _frameImagePath;
  late FrameTransform _frameTransform;
  late List<FeaturePoint> _featurePoints;
  late (int, int) _imageDimensions;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    _loadImageAndFeaturePoints();

    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadImageAndFeaturePoints() async {
    final project = await TimelapseStore.getProject(widget._projectName);
    final frame =
        await TimelapseFrame.fromExisting(widget._projectName, widget._uuid);

    // Get image and its dimensions
    _frameImagePath = frame.getFramePng().path;

    _frameImage = Image.file(File(_frameImagePath));
    _imageDimensions = await getImageDimensions(_frameImagePath);

    // Get frame transform feature points
    _frameTransform = frame.data.frameTransform;
    _featurePoints = List.from(frame.data.featurePoints);

    _useManualAlignment = frame.data.frameTransform.isKnown;
    _isFirstFrame = project.data.metaData.frames.indexOf(frame.uuid()!) == 0;

    // Work out if this is the first frame

    if (mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    // If using manual alignment, calculate frame transform
    if (_useManualAlignment) {
      _frameTransform =
          (await FrameAlignment.manual(widget._projectName, _featurePoints))
              .frameTransform;
    }

    final frame =
        await TimelapseFrame.fromExisting(widget._projectName, widget._uuid);

    // Update frame data
    frame.data.frameTransform = _frameTransform;
    frame.data.featurePoints = _featurePoints;

    // Save frame data
    frame.saveFrameDataOnly();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget buildAdjustmentSliders() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Brightness',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: brightness,
            min: -1.0,
            max: 1.0,
            divisions: 200,
            label: (brightness * 100).round().toString(),
            // label: 'Brightness: ${_brightness.toStringAsFixed(2)}',
            onChanged: (v) => setState(() => brightness = v)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Contrast',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: contrast,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            label: ((contrast * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => contrast = v)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'White Balance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: balanceFactor,
            min: -0.4,
            max: 0.4,
            divisions: 20,
            // label: ((contrast * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => balanceFactor = v)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Saturation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: saturation,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            label: ((saturation * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => saturation = v)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Overlay Opacity Control',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: opacity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: (opacity * 100).round().toString(),
            onChanged: (v) => setState(() => opacity = v)),
      ],
    );
  }

  // void deleteImage(int index) {
  //   setState(() {
  //     if (imagePaths.length == 1) {
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
  //     } else {
  //       imagePaths.removeAt(index);
  //     }
  //   });
  // }

  Future<Uint8List?> captureEditedImage() async {
    try {
      if (_boundaryKey.currentContext == null) {
        print("RepaintBoundary key is not attached to the widget tree");
        return null;
      }
      RenderRepaintBoundary boundary = _boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      if (boundary.size.isEmpty) {
        print("RepaintBoundary size is empty: ${boundary.size}");
        return null;
      }
      // Now we convert this to an image
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      //Then we can return the PNG in 'PNG bytes' format
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("There was a error. This is what it said: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final frameBackgroundKey = GlobalKey();
    final frameBackground = Opacity(
      key: frameBackgroundKey,
      opacity: 1,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix([
          contrast,
          0,
          0,
          0,
          brightness * 255,
          0,
          contrast,
          0,
          0,
          brightness * 255,
          0,
          0,
          contrast,
          0,
          brightness * 255,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix([
            0.2126 + 0.7874 * saturation,
            0.7152 - 0.7152 * saturation,
            0.0722 - 0.0722 * saturation,
            0,
            0,
            0.2126 - 0.2126 * saturation,
            0.7152 + 0.2848 * saturation,
            0.0722 - 0.0722 * saturation,
            0,
            0,
            0.2126 - 0.2126 * saturation,
            0.7152 - 0.7152 * saturation,
            0.0722 + 0.9278 * saturation,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix([
              1.0 + balanceFactor,
              0,
              0,
              0,
              0,
              0,
              1.0,
              0,
              0,
              0,
              0,
              0,
              1.0 - balanceFactor,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: _frameImage,
          ),
        ),
      ),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(_pageTitle),
          actions: [
            IconButton(
                onPressed: () => setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SettingsPage(widget._projectName)));
                    }),
                icon: const Icon(Icons.settings)),
            IconButton(
                icon:
                    Icon(showMarkers ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() {
                      showMarkers = !showMarkers;
                    }))
          ],
        ),
        body: Column(children: [
          SizedBox(
            height: 500,
            child: showMarkers
                ? FeaturePointsEditor(
                    featurePoints: _featurePoints,
                    allowDragging: !_useManualAlignment || _isFirstFrame,
                    backgroundImage: frameBackground,
                    backgroundImageKey: frameBackgroundKey,
                    backgroundImageDimensions: _imageDimensions,
                  )
                : frameBackground,
          ),
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Colour Grading'),
              Tab(text: 'Alignment'),
              // Tab(text: 'Frames',)
            ],
          ),
          Expanded(
              child: TabBarView(
            controller: tabController,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    buildAdjustmentSliders(),
                  ],
                ),
              ),
              _buildAlignmentTab(),
            ],
          )),
        ]),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                print("Save button pressed");

                await _saveChanges();

                if (mounted) {
                  Navigator.of(context).pushReplacement(InstantPageRoute(
                      builder: (context) =>
                          ProjectEditorPage(widget._projectName)));
                }
              },
              child: const Text(
                'Save and exit',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlignmentTab() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isFirstFrame)
                      Row(children: [
                        const Text("Use manual alignment"),
                        const Spacer(),
                        Switch(
                            value: _useManualAlignment,
                            onChanged: (_) {
                              _toggleManualAlignment();
                            })
                      ]),
                    const Text(
                      'Markers',
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _isFirstFrame
                          ? "As this is the first frame, these markers will be used as reference for future images"
                          : "Adjust the markers to match the reference image",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _featurePoints.length,
                  itemBuilder: (context, index) {
                    final featurePoint = _featurePoints[index];
                    return ListTile(
                      title: Text(featurePoint
                          .label), //_respectiveName == null ? Text(_respectiveName) : Text('Sam'),
                      tileColor:
                          selectedMarkerIndex == index ? Colors.grey : null,
                      onTap: () {
                        setState(() {
                          selectedMarkerIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleManualAlignment() async {
    if (_useManualAlignment) {
      // Switch to automatic alignment
      final automaticAlignment =
          await FrameAlignment.automatic(widget._projectName, _frameImagePath);

      if (automaticAlignment == null) {
        Fluttertoast.showToast(msg: "Automatic alignment failed");
        return;
      }

      _frameTransform = automaticAlignment.frameTransform;
      _featurePoints = automaticAlignment.featurePoints;
    }
    _useManualAlignment = !_useManualAlignment;

    if (mounted) {
      setState(() {});
    }
  }
}
