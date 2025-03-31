import 'dart:io';

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_alignment.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/ui/models/pending_frame.dart';
import 'package:chronolapse/ui/pages/frame_editor_page.dart';
import 'package:chronolapse/ui/shared/feature_points_editor.dart';
import 'package:chronolapse/util/util.dart';
import 'package:flutter/material.dart';

class FeaturePointsSetupPage extends StatefulWidget {
  final PendingFrame _pendingFrame;
  final bool isFirstFrame;

  const FeaturePointsSetupPage(this._pendingFrame,
      {this.isFirstFrame = false, super.key});

  @override
  State<StatefulWidget> createState() {
    return FeaturePointsSetupPageState();
  }
}

class FeaturePointsSetupPageState extends State<FeaturePointsSetupPage> {
  static const double _imageViewHeight = 600;
  static const int _minimumFeaturePoints = 4;

  late final List<FeaturePoint> _featurePoints;
  late final List<FeaturePoint> _referencePoints;

  late final Image _frameImage;
  late final GlobalKey _frameImageKey;
  late final (int, int) _frameImageDimensions;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    _frameImageKey = GlobalKey();
    _frameImage = Image.file(File(widget._pendingFrame.temporaryImagePath),
        key: _frameImageKey);
    _frameImageDimensions =
        await getImageDimensions(widget._pendingFrame.temporaryImagePath);

    // Get initial feature points
    if (widget.isFirstFrame) {
      // First frame, no feature points yet
      _featurePoints = [];
      _referencePoints = [];
    } else {
      // Use feature points from first frame as reference
      final project =
          await TimelapseStore.getProject(widget._pendingFrame.projectName);
      final firstFrameUuid = project.data.metaData.frames[0];
      final firstFrame = await TimelapseFrame.fromExisting(
          widget._pendingFrame.projectName, firstFrameUuid);

      _featurePoints = List.from(firstFrame.data.featurePoints);
      _referencePoints = firstFrame.data.featurePoints;
    }

    _loaded = true;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveAndExit() async {
    // Get frame alignment
    final alignment = widget.isFirstFrame
        ? FrameAlignment.baseFrame(_featurePoints)
        : await FrameAlignment.manual(
            widget._pendingFrame.projectName, _featurePoints);

    // Create frame
    final pendingFrame = widget._pendingFrame;
    pendingFrame.frameTransform = alignment.frameTransform;
    pendingFrame.featurePoints = alignment.featurePoints;

    final frame = await pendingFrame.saveInBackend();

    // Add frame transform to known frame transforms
    final project = await TimelapseStore.getProject(pendingFrame.projectName);
    project.data.knownFrameTransforms.frames.add(frame.uuid()!);
    project.saveChanges();

    // Continue to frame editor
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              FrameEditor(widget._pendingFrame.projectName, frame.uuid()!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final allowSaveAndExit = _featurePoints.length >= _minimumFeaturePoints;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(children: [
        Center(
            child: SizedBox(
                // box shouldn't be needed but it throws without an explicit height
                height: MediaQuery.of(context).size.width *
                    (_frameImageDimensions.$2.toDouble() /
                        _frameImageDimensions.$1.toDouble()),
                child: FeaturePointsEditor(
                  featurePoints: _featurePoints,
                  backgroundImage: _frameImage,
                  backgroundImageKey: _frameImageKey,
                  backgroundImageDimensions: _frameImageDimensions,
                  allowAdding: widget.isFirstFrame,
                  onPointAdded: () {
                    setState(() {});
                  },
                ))),
        Align(
            alignment: Alignment.bottomCenter,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.isFirstFrame
                        ? "Place at least $_minimumFeaturePoints markers on the image"
                        : "Move the markers to where they should appear on the image",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  )),
              Container(
                  padding: const EdgeInsets.all(25.0),
                  child: ElevatedButton(
                    onPressed: allowSaveAndExit ? _saveAndExit : null,
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor:
                            Theme.of(context).colorScheme.onSurface),
                    child: const Text("Save and continue"),
                  ))
            ]))
      ]),
    );
  }
}
