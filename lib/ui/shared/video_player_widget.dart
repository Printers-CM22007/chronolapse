import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerWidget extends StatefulWidget {
  /// Accepts an *uninitialised* `VideoPlayerController` which is shown as the
  /// content of the widget.
  const VideoPlayerWidget(this._chewieController,
      {super.key, this.forcedAspectRatio});

  final ChewieController _chewieController;
  final double? forcedAspectRatio;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: widget.forcedAspectRatio ??
            (widget._chewieController.aspectRatio ?? 16.0 / 9.0),
        child: Container(
          color: Colors.black26,
          child: Center(
              child: Chewie(
            controller: widget._chewieController,
          )),
        ));
  }
}
