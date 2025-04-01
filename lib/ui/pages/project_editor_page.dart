import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:chronolapse/ui/pages/frame_editor_page.dart';
import 'package:chronolapse/ui/shared/project_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../util/shared_keys.dart';
import '../shared/settings_cog.dart';

class _Frame {
  final String uuid;
  final Image image;
  final GlobalKey imageKey;

  const _Frame(this.uuid, this.image, this.imageKey);
}

const cannotDeleteFirstFrameText = "Cannot delete first frame";

class ProjectEditorPage extends StatefulWidget {
  final String _projectName;

  const ProjectEditorPage(this._projectName, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ProjectEditorPageState();
  }
}

class ProjectEditorPageState extends State<ProjectEditorPage> {
  late List<_Frame> _frames;
  bool _framesLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadFrames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Edit frames - ${widget._projectName}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[settingsCog(context, widget._projectName)],
      ),
      bottomNavigationBar: ProjectNavigationBar(widget._projectName, 1),
      body: _createFramesListView(),
    );
  }

  Future<void> _loadFrames() async {
    Future<_Frame> getFrame(String uuid) async {
      final imageKey = GlobalKey();
      final image = Image.file(
          (await TimelapseFrame.fromExisting(widget._projectName, uuid))
              .getFramePng(),
          key: imageKey);

      return _Frame(uuid, image, imageKey);
    }

    final project = await TimelapseStore.getProject(widget._projectName);

    _frames = await [
      for (var uuid in project.data.metaData.frames) getFrame(uuid)
    ].wait;

    if (mounted) {
      setState(() {
        _framesLoaded = true;
      });
    }
  }

  Widget _createFramesListView() {
    if (!_framesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        for (final (frameIndex, frame) in _frames.indexed)
          _createFrameCard(frameIndex, frame)
      ],
    );
  }

  Card _createFrameCard(int index, _Frame frame) {
    return Card(
        key: Key("$index"),
        surfaceTintColor: Theme.of(context).colorScheme.onPrimary,
        child: Column(
          children: [
            Column(
              children: [
                frame.image,
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 15.0,
                        children: [
                          Text(
                            "Frame ${index + 1}",
                            textScaler: const TextScaler.linear(2.0),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _onEditPressed(index);
                            },
                            icon: const Icon(Icons.edit, size: 40.0),
                            key: projectEditorFrameEditButton,
                            style: IconButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              backgroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (index != 0) {
                                _onDeletePressed(index);
                              } else {
                                _showToast(cannotDeleteFirstFrameText);
                              }
                            },
                            icon: const Icon(Icons.delete, size: 40.0),
                            style: IconButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              backgroundColor: index != 0
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.grey,
                            ),
                          ),
                        ])),
              ],
            )
          ],
        ));
  }

  void _onEditPressed(int frameIndex) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            FrameEditor(widget._projectName, _frames[frameIndex].uuid)));
  }

  void _onDeletePressed(int frameIndex) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deleting Frame ${frameIndex + 1}"),
            content:
                Text("Are you sure you want to delete Frame ${frameIndex + 1}"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: () {
                  _onDeleteConfirmed(frameIndex);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          );
        });
  }

  void _onDeleteConfirmed(int frameIndex) async {
    final project = await TimelapseStore.getProject(widget._projectName);

    await project.deleteFrame(frameIndex);
    await project.saveChanges();

    _loadFrames();
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
