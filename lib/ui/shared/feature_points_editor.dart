import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:chronolapse/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FeaturePointsEditor extends StatefulWidget {
  final List<FeaturePoint> featurePoints;
  final Widget backgroundImage;
  final GlobalKey backgroundImageKey;
  final (int, int) backgroundImageDimensions;
  final bool allowAdding;
  final bool allowDragging;
  final void Function()? onPointAdded;

  const FeaturePointsEditor(
      {required this.featurePoints,
      required this.backgroundImage,
      required this.backgroundImageKey,
      required this.backgroundImageDimensions,
      this.allowAdding = false,
      this.allowDragging = true,
      this.onPointAdded,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return FeaturePointsEditorState();
  }
}

class FeaturePointsEditorState extends State<FeaturePointsEditor> {
  late Size _backgroundSize;
  bool _hasBackgroundConstraints = false;

  final _newMarkerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasBackgroundConstraints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Get constraints of background image
        RenderBox box = widget.backgroundImageKey.currentContext!
            .findRenderObject() as RenderBox;

        setState(() {
          _backgroundSize = box.size;
          _hasBackgroundConstraints = true;
        });
      });
    }

    // Create feature point marker widgets
    final List<FeaturePointMarker> featurePointMarkers =
        _hasBackgroundConstraints
            ? [
                for (var i = 0; i < widget.featurePoints.length; i++)
                  FeaturePointMarker(i, this),
              ]
            : [];

    return GestureDetector(
        onTapUp: _onTapCanvas,
        child: Stack(alignment: Alignment.center, children: [
          widget.backgroundImage,
          Stack(children: featurePointMarkers),
        ]));
  }

  void _onTapCanvas(TapUpDetails tapUpDetails) {
    if (widget.allowAdding) {
      final pointIndex = widget.featurePoints.length;
      final defaultName = "Marker ${pointIndex + 1}";

      _newMarkerNameController.clear();

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text("Create marker"),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);

                    setState(() {
                      widget.featurePoints.add(FeaturePoint(
                          _newMarkerNameController.text.trim().isNotEmpty
                              ? _newMarkerNameController.text.trim()
                              : defaultName,
                          randomPastelColor(),
                          _transformScreenToImage(FeaturePointPosition(
                              tapUpDetails.localPosition.dx,
                              tapUpDetails.localPosition.dy))));

                      if (widget.onPointAdded != null) {
                        widget.onPointAdded!();
                      }

                      setState(() {});
                    });
                  },
                  child: const Text("Create"),
                )
              ],
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //User input for project name
                  TextField(
                    controller: _newMarkerNameController,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    decoration: InputDecoration(
                        hintText: defaultName,
                        hintStyle: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white38)),
                  )
                ],
              )));
    }
  }

  /// Clamp feature point position to image bounds
  FeaturePointPosition _clampImagePosition(FeaturePointPosition pos) {
    return FeaturePointPosition(
        pos.x.clamp(0.0, widget.backgroundImageDimensions.$1.toDouble()),
        pos.y.clamp(0.0, widget.backgroundImageDimensions.$2.toDouble()));
  }

  /// Transform feature point position from screen-space to image-space
  FeaturePointPosition _transformScreenToImage(FeaturePointPosition pos) {
    final scaleX =
        widget.backgroundImageDimensions.$1.toDouble() / _backgroundSize.width;
    final scaleY =
        widget.backgroundImageDimensions.$2.toDouble() / _backgroundSize.height;

    return FeaturePointPosition(pos.x * scaleX, pos.y * scaleY);
  }

  /// Transform feature point position from image-space to screen-space
  FeaturePointPosition _transformImageToScreen(FeaturePointPosition pos) {
    final scaleX =
        widget.backgroundImageDimensions.$1.toDouble() / _backgroundSize.width;
    final scaleY =
        widget.backgroundImageDimensions.$2.toDouble() / _backgroundSize.height;

    return FeaturePointPosition(pos.x / scaleX, pos.y / scaleY);
  }
}

class FeaturePointMarker extends StatefulWidget {
  final int _featurePointIndex; // index of this feature point
  final FeaturePointsEditorState _editorState;

  const FeaturePointMarker(this._featurePointIndex, this._editorState,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return FeaturePointMarkerState();
  }
}

class FeaturePointMarkerState extends State<FeaturePointMarker> {
  @override
  Widget build(BuildContext context) {
    const iconSize = 20.0;

    final featurePoint =
        widget._editorState.widget.featurePoints[widget._featurePointIndex];

    final (r, g, b) = featurePoint.color ?? (255, 0, 0);

    final positionScreen =
        widget._editorState._transformImageToScreen(featurePoint.position);

    return Stack(
      children: [
        Positioned(
            left: positionScreen.x - 50,
            top: positionScreen.y - 30,
            child: SizedBox(
                width: 100,
                height: 100,
                child: Center(
                    child: Text(" ${featurePoint.label} ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            backgroundColor: Colors.black.withAlpha(50)))))),
        Positioned(
            left: positionScreen.x - iconSize / 2.0,
            top: positionScreen.y - iconSize / 2.0,
            child: GestureDetector(
                onPanUpdate: (dragUpdateDetails) {
                  setState(() {
                    if (!widget._editorState.widget.allowDragging) {
                      return;
                    }

                    final old = widget._editorState.widget
                        .featurePoints[widget._featurePointIndex];

                    // Taking advantage of List's mutability to hack state change
                    widget._editorState.widget
                            .featurePoints[widget._featurePointIndex] =
                        FeaturePoint(
                            old.label,
                            old.color,
                            widget._editorState._clampImagePosition(widget
                                ._editorState
                                ._transformScreenToImage(widget._editorState
                                    ._transformImageToScreen(old.position)
                                    .move(dragUpdateDetails.delta.dx,
                                        dragUpdateDetails.delta.dy))));
                  });
                },
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(children: [
                      Container(
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.33),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 0),
                            )
                          ]),
                          child: Icon(
                            Icons.circle,
                            color: Color.fromRGBO(r, g, b, 1.0),
                            size: iconSize,
                            key: getFeaturePointMarkerKey(
                                widget._featurePointIndex),
                          )),
                    ])))),
      ],
    );
  }
}
