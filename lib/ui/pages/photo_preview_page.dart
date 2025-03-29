import 'dart:io';

import 'package:chronolapse/ui/models/pending_frame.dart';
import 'package:chronolapse/ui/pages/feature_points_setup_page.dart';
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
              isFirstFrame: isFirstFrame)));
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
