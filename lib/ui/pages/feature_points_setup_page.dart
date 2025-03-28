import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/ui/pages/frame_editting_page.dart';
import 'package:chronolapse/ui/shared/feature_points_editor.dart';
import 'package:chronolapse/util/util.dart';
import 'package:flutter/material.dart';

class FeaturePointsSetupPage extends StatefulWidget {
  final String _projectName;
  final String _frameUuid;

  FeaturePointsSetupPage(this._projectName, this._frameUuid, {super.key});

  @override
  State<StatefulWidget> createState() {
    return FeaturePointsSetupPageState();
  }
}

class FeaturePointsSetupPageState extends State<FeaturePointsSetupPage> {
  static const double _imageViewHeight = 600;
  static const int _minimumFeaturePoints = 3;

  List<FeaturePoint> _featurePoints = [];

  late Image _frameImage;
  late GlobalKey _frameImageKey;
  late (int, int) _frameImageDimensions;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    final frame = await TimelapseFrame.fromExisting(
        widget._projectName, widget._frameUuid);

    final imageFile = frame.getFramePng();

    _frameImageKey = GlobalKey();
    _frameImage = Image.file(imageFile, key: _frameImageKey);
    _frameImageDimensions = await getImageDimensions(imageFile.path);
    _loaded = true;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveAndExit() async {
    final frame = await TimelapseFrame.fromExisting(
        widget._projectName, widget._frameUuid);

    // Set feature points
    frame.data.featurePoints = _featurePoints;
    frame.saveFrameDataOnly();

    // Continue to frame editor
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              FrameEditor(widget._projectName, widget._frameUuid)));
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
      body: Column(children: [
        const Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              "Please mark up to 3 feature points on the image",
              style: TextStyle(color: Colors.white, fontSize: 30),
              textAlign: TextAlign.center,
            )),
        SizedBox(
          height: _imageViewHeight,
          child: FeaturePointsEditor(
            featurePoints: _featurePoints,
            backgroundImage: _frameImage,
            backgroundImageKey: _frameImageKey,
            backgroundImageDimensions: _frameImageDimensions,
            allowAdding: true,
            onPointAdded: () {
              setState(() {});
            },
          ),
        ),
        ElevatedButton(
          onPressed: allowSaveAndExit ? _saveAndExit : null,
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Theme.of(context).colorScheme.onSurface),
          child: const Text("Save and continue"),
        )
      ]),
    );
  }
}
