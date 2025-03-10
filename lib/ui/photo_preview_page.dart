import 'dart:io';

import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:flutter/material.dart';

class PhotoPreviewPage extends StatefulWidget {
  final String _projectName;
  final String _picturePath;

  const PhotoPreviewPage(this._projectName, this._picturePath, {super.key});

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
    // Save photo into timelapse storage
    final frame = TimelapseFrame.createNew(widget._projectName);
    await frame.saveFrameFromPngFile(File(widget._picturePath));

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _onRejectPressed() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image(image: FileImage(File(widget._picturePath))),
      Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(25.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
                  "Accept",
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
            onPressed: _onRejectPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                Text(
                  "Reject",
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
