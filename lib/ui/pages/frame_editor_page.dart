// import 'dart:ui';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/ui/pages/export_page.dart';
import 'package:chronolapse/ui/shared/feature_points_editor.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:chronolapse/util/util.dart';
import 'package:flutter/material.dart';
import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/ui/pages/photo_taking_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../backend/timelapse_storage/frame/timelapse_frame.dart';
import '../../backend/timelapse_storage/timelapse_data.dart';
import '../../backend/timelapse_storage/timelapse_store.dart';

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

  int? selectedMarkerIndex;
  bool showMarkers = true;
  bool isDragging = false;

  final GlobalKey _boundaryKey = GlobalKey();

  late TabController tabController;

  late Image _frameImage;
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
    final frame =
        await TimelapseFrame.fromExisting(widget._projectName, widget._uuid);

    // Get image and its dimensions
    final imagePath = frame.getFramePng().path;

    _frameImage = Image.file(File(imagePath));
    _imageDimensions = await getImageDimensions(imagePath);

    // Get feature points
    _featurePoints = List.from(frame.data.featurePoints);

    if (mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    final frame =
        await TimelapseFrame.fromExisting(widget._projectName, widget._uuid);

    frame.data.featurePoints = _featurePoints;
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
          title: Text(_pageTitle),
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
            child: FeaturePointsEditor(
              featurePoints: _featurePoints,
              backgroundImage: frameBackground,
              backgroundImageKey: frameBackgroundKey,
              backgroundImageDimensions: _imageDimensions,
            ),
          ),
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Sliders'),
              Tab(text: 'Markers'),
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
              Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Markers',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Adjust the markers to match the reference image',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
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
                                tileColor: selectedMarkerIndex == index
                                    ? Colors.grey
                                    : null,
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
              ),
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

                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => const DashboardPage()));
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
}

class VideoEditorNavigationBar extends StatelessWidget {
  final int selectedIndex;

  final dynamic _projectName;

  const VideoEditorNavigationBar(this.selectedIndex, this._projectName,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(35),
        //   topRight: Radius.circular(35)
        // ),
        // boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 1)]
      ),
      child: NavigationBar(
          shadowColor: Theme.of(context).colorScheme.onInverseSurface,
          height: 60,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          selectedIndex: selectedIndex,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => const DashboardPage()));
                break;

              case 1:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExportPage(_projectName)));
                break;

              case 2:
                // Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoTakingPage(widget._projectName)));
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => PhotoTakingPage(_projectName)));
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.dashboard,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Dashboard",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.share,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Export",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Take Photo",
            ),
          ]),
    );
  }
}
