import 'package:json_annotation/json_annotation.dart';

part 'feature_points.g.dart';

@JsonSerializable()
class FeaturePointPosition {
  final double x;
  final double y;

  const FeaturePointPosition(this.x, this.y);

  FeaturePointPosition move(double dx, double dy) {
    return FeaturePointPosition(
      x + dx,
      y + dy,
    );
  }

  factory FeaturePointPosition.fromJson(Map<String, dynamic> json) =>
      _$FeaturePointPositionFromJson(json);

  Map<String, dynamic> toJson() => _$FeaturePointPositionToJson(this);
}

@JsonSerializable()
class FeaturePoint {
  final String label;
  final FeaturePointPosition position;

  const FeaturePoint(this.label, this.position);

  factory FeaturePoint.fromJson(Map<String, dynamic> json) =>
      _$FeaturePointFromJson(json);

  Map<String, dynamic> toJson() => _$FeaturePointToJson(this);
}
