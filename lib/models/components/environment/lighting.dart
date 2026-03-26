import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

/// Class used to configure lighting
class LightingConfig {
  /// Radius of the lighting
  final double radius;

  /// Color of the lighting
  final Color color;

  /// Enable pulse effect in lighting
  final bool withPulse;

  /// Light follow component angle
  final bool useComponentAngle;

  /// Configure variation in pulse effect
  final double pulseVariation;

  /// Configure speed in pulse effect
  final double pulseSpeed;

  /// Configure curve in pulse effect
  final Curve pulseCurve;

  /// Configure blur in lighting
  final double blurBorder;

  /// Configure type of the lighting
  final LightingType type;

  final Vector2 align;

  late MaskFilter _maskFilter;

  PulseValue? _pulseAnimation;

  LightingConfig({
    required this.radius,
    required this.color,
    this.withPulse = false,
    this.useComponentAngle = false,
    this.pulseCurve = Curves.decelerate,
    this.pulseVariation = 0.1,
    this.pulseSpeed = 0.1,
    double? blurBorder,
    this.type = LightingType.circle,
    Vector2? align,
  })  : align = align ?? Vector2.zero(),
        blurBorder = blurBorder ?? radius {
    _pulseAnimation = PulseValue(
      speed: pulseSpeed,
      curve: pulseCurve,
      pulseVariation: pulseVariation,
    );

    _maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      _convertRadiusToSigma(this.blurBorder),
    );
  }

  void update(double dt) {
    if (withPulse) {
      _pulseAnimation?.update(dt);
    }
  }

  double get valuePulse => _pulseAnimation?.value ?? 0.0;
  MaskFilter get maskFilter => _maskFilter;

  static double _convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  LightingConfig copyWith({
    double? radius,
    Color? color,
    bool? withPulse,
    bool? useComponentAngle,
    double? pulseVariation,
    double? pulseSpeed,
    Curve? pulseCurve,
    double? blurBorder,
    LightingType? type,
  }) {
    return LightingConfig(
      radius: radius ?? this.radius,
      color: color ?? this.color,
      withPulse: withPulse ?? this.withPulse,
      useComponentAngle: useComponentAngle ?? this.useComponentAngle,
      pulseVariation: pulseVariation ?? this.pulseVariation,
      pulseSpeed: pulseSpeed ?? this.pulseSpeed,
      pulseCurve: pulseCurve ?? this.pulseCurve,
      blurBorder: blurBorder ?? this.blurBorder,
      type: type ?? this.type,
    );
  }
}

class LightingType {
  const LightingType();
  static const LightingType circle = CircleLightingType();
  static ArcLightingType arc({
    required double endRadAngle,
    double startRadAngle = 0,
    bool isCenter = false,
  }) =>
      ArcLightingType(
        endRadAngle: endRadAngle,
        startRadAngle: startRadAngle,
        isCenter: isCenter,
      );
}

class CircleLightingType extends LightingType {
  const CircleLightingType();
}

class ArcLightingType extends LightingType {
  final double endRadAngle;
  final double startRadAngle;
  final bool isCenter;
  const ArcLightingType({
    required this.endRadAngle,
    this.startRadAngle = 0,
    this.isCenter = false,
  });
}

class PulseValue {
  final double speed;
  final Curve curve;
  final double pulseVariation;
  double value = 0;
  bool _animIsReverse = false;
  double _controlAnim = 0;
  PulseValue({
    this.speed = 1,
    this.curve = Curves.decelerate,
    this.pulseVariation = 0.1,
  });

  void update(double dt) {
    if (_animIsReverse) {
      _controlAnim -= dt * speed;
    } else {
      _controlAnim += dt * speed;
    }

    if (_controlAnim >= pulseVariation) {
      _controlAnim = pulseVariation;
      _animIsReverse = true;
    }
    if (_controlAnim <= 0) {
      _controlAnim = 0;
      _animIsReverse = false;
    }
    value = Curves.decelerate.transform(_controlAnim);
  }
}