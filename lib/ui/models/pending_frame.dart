import 'package:chronolapse/backend/image_transformer/feature_points.dart';
import 'package:flutter/material.dart';

class PendingFrame {
  final String projectName;
  final int frameIndex;
  String imagePath;
  List<FeaturePoint>? featurePoints;

  PendingFrame(
      {required this.projectName,
      required this.frameIndex,
      required this.imagePath});
}
