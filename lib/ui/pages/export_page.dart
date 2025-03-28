import 'dart:io';

import 'package:chronolapse/ui/shared/project_navigation_bar.dart';
import 'package:chronolapse/ui/shared/settings_cog.dart';
import 'package:chronolapse/ui/shared/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
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

  void _startVideoGeneration() async {
    if (_generatingVideo) {
      return;
    }
    setState(() {
      _generatingVideo = true;
      _videoPath = null;
    });

    // Generation code here
    await Future.delayed(const Duration(seconds: 5));
    final path =
        "${(await getApplicationDocumentsDirectory()).path}/earth-video.mp4";
    print(path);

    setState(() {
      _videoPath = path;
      _generatingVideo = false;
    });
  }

  Widget _generationIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
            color: Theme.of(context).secondaryHeaderColor),
        Text(
          "Generating timelapse...",
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
      ],
    );
  }

  Widget _videoTile() {
    if (_videoPath != null) {
      return VideoPlayerWidget(VideoPlayerController.file(File(_videoPath!)));
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
                    _startVideoGeneration();
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              result
                                  ? "Video saved successfully"
                                  : "Video failed to save",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.black54,
                        ),
                      );
                    }
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
}

Future<bool> saveVideoToGallery(String videoPath) async {
  if (await Permission.storage.request().isGranted) {
    return await GallerySaver.saveVideo(videoPath) ?? false;
  } else {
    print("Permissions failed");
    return false;
  }
}
