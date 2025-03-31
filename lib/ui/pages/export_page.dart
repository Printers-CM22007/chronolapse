import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/backend/video_generator/video_generator.dart';
import 'package:chronolapse/ui/shared/project_navigation_bar.dart';
import 'package:chronolapse/ui/shared/settings_cog.dart';
import 'package:chronolapse/ui/shared/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class ExportPage extends StatefulWidget {
  final String _projectName;

  const ExportPage(this._projectName, {super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String? _videoPath;
  bool _generatingVideo = false;
  bool _isSaving = false;
  String? _generationProgress;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasEnoughFrames = false;

  Future<void> _disposeVideo() async {
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
    }
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
  }

  void _startVideoGeneration() async {
    if (_generatingVideo) {
      return;
    }
    await cleanupGeneratedVideo();

    await _disposeVideo();
    setState(() {
      _generatingVideo = true;
      _videoPath = null;
      _generationProgress = null;
    });

    final result = await generateVideo(widget._projectName, (val) {
      setState(() {
        _generationProgress = val;
      });
    });

    if (result.path != null) {
      // final videoPlayerController = VideoPlayerController.networkUrl(
      //     Uri.parse(
      //         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
      //     )
      // );
      await Future.delayed(const Duration(seconds: 1));
      final videoPlayerController = VideoPlayerController.file(File(result.path!));
      // final videoPlayerController = VideoPlayerController.contentUri(Uri.file(result.path!));
      // final videoPlayerController = VideoPlayerController.asset("cat_video.mp4");
      await videoPlayerController.initialize();
      final chewieController = ChewieController(videoPlayerController: videoPlayerController);
      setState(() {
        _videoPath = result.path;
        _videoPlayerController = videoPlayerController;
        _chewieController = chewieController;
        _generatingVideo = false;
        _generationProgress = null;
      });
    } else {
      await _disposeVideo();
      setState(() {
        _videoPath = null;
        _videoPlayerController = null;
        _generatingVideo = false;
        _generationProgress = null;
      });
      _showToast(result.error!);
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  Widget _generationIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
            color: Theme.of(context).secondaryHeaderColor),
        Text(
          _generationProgress == null
              ? "Generating timelapse..."
              : _generationProgress!,
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
      ],
    );
  }

  Widget _videoTile() {
    if (_chewieController != null) {
      return VideoPlayerWidget(_chewieController!);
    } else {
      return Container(
        color: Theme.of(context).primaryColorLight,
        child: AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: Center(
              child: _generatingVideo
                  ? _generationIndicator()
                  : Text(
                      "Click 'Generate Timelapse' to generate",
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor),
                    )),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkForFrames();
  }

  Future<void> _checkForFrames() async {
    _hasEnoughFrames = (await TimelapseStore.getProject(widget._projectName)).data.metaData.frames.length > 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text("Export '${widget._projectName}'",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: <Widget>[
            settingsCog(context, widget._projectName,
                enabled: !_generatingVideo)
          ],
        ),
        bottomNavigationBar: ProjectNavigationBar(widget._projectName, 2,
            disabled: _generatingVideo),
        body: PopScope<Object?>(
          canPop: !_generatingVideo,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.mediation),
                  title: const Text('Generate Timelapse'),
                  subtitle: const Text('Saves timelapse to camera roll'),
                  onTap: () {
                    if (_hasEnoughFrames) {
                      _startVideoGeneration();
                    }
                    else {
                      _showToast("You need to take more images to make a timelapse");
                    }
                  },
                  enabled: !_generatingVideo,
                ),
                _videoTile(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Save Timelapse'),
                  subtitle: const Text('Saves timelapse to camera roll'),
                  onTap: () async {
                    if (_videoPath == null) {
                      return;
                    }
                    setState(() {
                      _isSaving = true;
                    });
                    final result = await saveVideoToGallery(_videoPath!);
                    setState(() {
                      _isSaving = false;
                    });
                    _showToast(result
                        ? "Video saved successfully"
                        : "Video failed to save");
                  },
                  enabled: _videoPath != null && !_isSaving,
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share Timelapse'),
                  subtitle: const Text(
                      'Send your timelapse to someone or upload it to social media'),
                  onTap: () {
                    if (_videoPath == null) {
                      return;
                    }
                    Share.shareXFiles([XFile(_videoPath!)],
                        text: "Check out this timelapse!");
                  },
                  enabled: _videoPath != null,
                ),
              ],
            ),
          ),
        ));
  }

  void _showToast(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.black54,
        ),
      );
    }
  }
}

Future<bool> saveVideoToGallery(String videoPath) async {
  if (await Permission.storage.request().isGranted && await Permission.photos.request().isGranted && await Permission.videos.request().isGranted) {
    return await GallerySaver.saveVideo(videoPath) ?? false;
  } else {
    print("Permissions failed");
    return false;
  }
}
