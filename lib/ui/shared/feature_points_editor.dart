import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:flutter/material.dart';

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

    final positionScreen = _transformImageToScreen(widget
        ._editorState.widget.featurePoints[widget._featurePointIndex].position);

    return Positioned(
        left: positionScreen.x - iconSize / 2.0,
        top: positionScreen.y - iconSize / 2.0,
        child: GestureDetector(
            onPanUpdate: (dragUpdateDetails) {
              setState(() {
                // Taking advantage of List's mutability to hack state change
                final old = widget._editorState.widget
                    .featurePoints[widget._featurePointIndex];

                widget._editorState.widget
                        .featurePoints[widget._featurePointIndex] =
                    FeaturePoint(
                        old.label,
                        _clampImagePosition(_transformScreenToImage(
                            _transformImageToScreen(old.position).move(
                                dragUpdateDetails.delta.dx,
                                dragUpdateDetails.delta.dy))));
              });
            },
            child: const Icon(
              Icons.circle,
              color: Colors.red,
              size: iconSize,
            )));
  }

  /// Clamp feature point position to image bounds
  FeaturePointPosition _clampImagePosition(FeaturePointPosition pos) {
    return FeaturePointPosition(
        pos.x.clamp(0.0,
            widget._editorState.widget.backgroundImageDimensions.$1.toDouble()),
        pos.y.clamp(
            0.0,
            widget._editorState.widget.backgroundImageDimensions.$2
                .toDouble()));
  }

  /// Transform feature point position from screen-space to image-space
  FeaturePointPosition _transformScreenToImage(FeaturePointPosition pos) {
    final scaleX =
        widget._editorState.widget.backgroundImageDimensions.$1.toDouble() /
            widget._editorState._backgroundSize.width;
    final scaleY =
        widget._editorState.widget.backgroundImageDimensions.$2.toDouble() /
            widget._editorState._backgroundSize.height;

    final offsetX = widget._editorState._backgroundOffset.dx;
    //final offsetY = widget._editorState._backgroundOffset.dy;
    const offsetY = 0.0;

    return FeaturePointPosition(
        (pos.x - offsetX) * scaleX, (pos.y - offsetY) * scaleY);
  }

  /// Transform feature point position from image-space to screen-space
  FeaturePointPosition _transformImageToScreen(FeaturePointPosition pos) {
    final scaleX =
        widget._editorState.widget.backgroundImageDimensions.$1.toDouble() /
            widget._editorState._backgroundSize.width;
    final scaleY =
        widget._editorState.widget.backgroundImageDimensions.$2.toDouble() /
            widget._editorState._backgroundSize.height;

    final offsetX = widget._editorState._backgroundOffset.dx;
    //final offsetY = widget._editorState._backgroundOffset.dy;
    const offsetY = 0.0;

    return FeaturePointPosition(
        pos.x / scaleX + offsetX, pos.y / scaleY + offsetY);
  }
}

class FeaturePointsEditor extends StatefulWidget {
  final List<FeaturePoint> featurePoints;
  final Widget backgroundImage;
  final GlobalKey backgroundImageKey;
  final (int, int) backgroundImageDimensions;

  const FeaturePointsEditor(
      {required this.featurePoints,
      required this.backgroundImage,
      required this.backgroundImageKey,
      required this.backgroundImageDimensions,
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
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get constraints of background image
      RenderBox box = widget.backgroundImageKey.currentContext!
          .findRenderObject() as RenderBox;

      setState(() {
        _backgroundOffset = box.localToGlobal(Offset.zero);
        _backgroundSize = box.size;
        _hasBackgroundConstraints = true;
      });
    });

    // Create feature point marker widgets
    final List<FeaturePointMarker> featurePointMarkers =
        _hasBackgroundConstraints
            ? [
                for (var i = 0; i < widget.featurePoints.length; i++)
                  FeaturePointMarker(i, this),
              ]
            : [];

    return Stack(alignment: Alignment.center, children: [
      widget.backgroundImage,
      GestureDetector(child: Stack(children: featurePointMarkers)),
    ]);
  }
}
