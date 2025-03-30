import 'dart:io';

import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/image_transformer/frame_alignment.dart';
import 'package:chronolapse/backend/image_transformer/frame_transforms.dart';
import 'package:chronolapse/backend/image_transformer/image_transformer.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/ui/models/pending_frame.dart';
import 'package:chronolapse/ui/pages/feature_points_setup_page.dart';
import 'package:chronolapse/ui/pages/frame_editor_page.dart';
import 'package:flutter/material.dart';

class PhotoPreviewPage extends StatefulWidget {
  final PendingFrame _pendingFrame;

  const PhotoPreviewPage(this._pendingFrame, {super.key});

  @override
  State<StatefulWidget> createState() {
    return PhotoPreviewPageState();
  }
}

class PhotoPreviewPageState extends State<PhotoPreviewPage> {
  @override
  void initState() {
    super.initState();
  }

  void _onAcceptPressed() async {
    final isFirstFrame = widget._pendingFrame.frameIndex == 0;

    if (isFirstFrame) {
      // Continue to feature points setup page
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => FeaturePointsSetupPage(widget._pendingFrame,
              isFirstFrame: true)));
    } else {
      // Try automatic alignment
      final automaticAlignment = await FrameAlignment.automatic(
          widget._pendingFrame.projectName,
          widget._pendingFrame.temporaryImagePath);

      if (automaticAlignment != null) {
        // Successful automatic alignment
        final pendingFrame = widget._pendingFrame;

        pendingFrame.frameTransform = automaticAlignment.frameTransform;
        pendingFrame.featurePoints = automaticAlignment.featurePoints;

        final frame = await pendingFrame.saveInBackend();

        if (mounted) {
          // Continue to frame editor
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  FrameEditor(pendingFrame.projectName, frame.uuid()!)));
        }
      } else {
        // Automatic alignment failed; require manual alignment
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => FeaturePointsSetupPage(widget._pendingFrame,
                  isFirstFrame: false)));
        }
      }
    }
  }

  void _onRejectPressed() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image(image: FileImage(File(widget._pendingFrame.temporaryImagePath))),
      Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(25.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inverseSurface),
            onPressed: _onRejectPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                )
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inverseSurface),
            onPressed: _onAcceptPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                Text(
                  "Continue",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}
