import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  /// Accepts an *uninitialised* `VideoPlayerController` which is shown as the
  /// content of the widget.
  const VideoPlayerWidget(this._videoPlayerController,
      {super.key, this.forcedAspectRatio});

  final VideoPlayerController _videoPlayerController;
  final double? forcedAspectRatio;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  ChewieController? _chewieController;

  @override
  void initState() {
    _initVideoPlayer();
    super.initState();
  }

  Future<void> _initVideoPlayer() async {
    await widget._videoPlayerController.initialize();

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: widget._videoPlayerController,
        autoPlay: false,
        looping: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: widget.forcedAspectRatio ??
            (_chewieController?.aspectRatio ?? 16.0 / 9.0),
        child: Container(
          color: Colors.black26,
          child: Center(
            child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Loading'),
                    ],
                  ),
          ),
        ));
  }
}
