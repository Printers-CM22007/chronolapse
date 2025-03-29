import 'package:chronolapse/backend/image_transformer/feature_points.dart';
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
  late Offset _backgroundOffset;
  late Size _backgroundSize;
  bool _hasBackgroundConstraints = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Get constraints of background image
      RenderBox box = widget.backgroundImageKey.currentContext!
          .findRenderObject() as RenderBox;

      setState(() {
        _backgroundOffset = box.localToGlobal(Offset.zero);
        _backgroundSize = box.size;
        _hasBackgroundConstraints = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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

      widget.featurePoints.add(FeaturePoint(
          "Marker ${pointIndex + 1}",
          randomPastelColor(),
          _transformScreenToImage(FeaturePointPosition(
              tapUpDetails.localPosition.dx, tapUpDetails.localPosition.dy))));

      if (widget.onPointAdded != null) {
        widget.onPointAdded!();
      }

      setState(() {});
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

    final offsetX = _backgroundOffset.dx;
    //final offsetY = _backgroundOffset.dy;
    const offsetY = 0.0;

    return FeaturePointPosition(
        (pos.x - offsetX) * scaleX, (pos.y - offsetY) * scaleY);
  }

  /// Transform feature point position from image-space to screen-space
  FeaturePointPosition _transformImageToScreen(FeaturePointPosition pos) {
    final scaleX =
        widget.backgroundImageDimensions.$1.toDouble() / _backgroundSize.width;
    final scaleY =
        widget.backgroundImageDimensions.$2.toDouble() / _backgroundSize.height;

    final offsetX = _backgroundOffset.dx;
    //final offsetY = _backgroundOffset.dy;
    const offsetY = 0.0;

    return FeaturePointPosition(
        pos.x / scaleX + offsetX, pos.y / scaleY + offsetY);
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
            child: Container(
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
                          )),
                    ])))),
      ],
    );
  }
}
