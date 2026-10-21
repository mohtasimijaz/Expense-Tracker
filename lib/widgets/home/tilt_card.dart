import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../utils/app_routes.dart';

/// Gives [child] a subtle 3D tilt that follows the phone's motion (or the
/// mouse on web/desktop), with a soft light reflection that moves across it.
///
/// Sensor listening pauses whenever the card is not on screen (hidden tab)
/// and is off entirely when "reduce motion" is enabled.
class TiltCard extends StatefulWidget {
  /// Creates a tilting wrapper.
  const TiltCard({super.key, required this.child, required this.radius});

  /// Set to `false` in tests (no sensor plugin there).
  static bool sensorsEnabled = true;

  final Widget child;

  /// Corner radius of the child, so the reflection is clipped to match.
  final double radius;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  static const double _maxTilt = 0.07; // radians (~4°)
  static const double _gravity = 9.81;
  static const double _smoothing = 0.15;
  static const double _perspective = 0.0012;
  static const double _shineOpacity = 0.16;

  final ValueNotifier<Offset> _tilt = ValueNotifier(Offset.zero);
  StreamSubscription<AccelerometerEvent>? _sensor;
  ValueListenable<bool>? _tickerMode;
  Offset? _neutral;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerMode?.removeListener(_updateSensor);
    _tickerMode = TickerMode.getNotifier(context)..addListener(_updateSensor);
    _updateSensor();
  }

  @override
  void dispose() {
    _tickerMode?.removeListener(_updateSensor);
    _sensor?.cancel();
    _tilt.dispose();
    super.dispose();
  }

  bool get _shouldListen =>
      TiltCard.sensorsEnabled &&
      (_tickerMode?.value ?? false) &&
      AppMotion.enabled(context);

  void _updateSensor() {
    if (_shouldListen && _sensor == null) {
      try {
        _sensor = accelerometerEventStream(
          samplingPeriod: SensorInterval.uiInterval,
        ).listen(_onMotion, onError: (Object _) => _stopSensor());
      } catch (_) {
        _sensor = null;
      }
    } else if (!_shouldListen) {
      _stopSensor();
    }
  }

  void _stopSensor() {
    _sensor?.cancel();
    _sensor = null;
    _neutral = null;
    _tilt.value = Offset.zero;
  }

  void _onMotion(AccelerometerEvent event) {
    final reading = Offset(event.x / _gravity, event.y / _gravity);
    final neutral = _neutral ??= reading; // how the phone is usually held
    final target = Offset(
      (reading.dx - neutral.dx).clamp(-1.0, 1.0),
      (reading.dy - neutral.dy).clamp(-1.0, 1.0),
    );
    _tilt.value = Offset.lerp(_tilt.value, target, _smoothing)!;
  }

  void _onHover(PointerHoverEvent event, Size size) {
    if (!AppMotion.enabled(context) || size.isEmpty) return;
    _tilt.value = Offset(
      (event.localPosition.dx / size.width) * 2 - 1,
      (event.localPosition.dy / size.height) * 2 - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onHover: (e) => _onHover(e, constraints.biggest),
        onExit: (_) => _tilt.value = Offset.zero,
        child: ValueListenableBuilder<Offset>(
          valueListenable: _tilt,
          child: widget.child,
          builder: (context, tilt, child) => TweenAnimationBuilder<Offset>(
            tween: Tween(end: tilt),
            duration: AppDurations.fast,
            builder: (context, t, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(-t.dy * _maxTilt)
                ..rotateY(t.dx * _maxTilt),
              child: Stack(
                children: [
                  child!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.radius),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(-t.dx, -t.dy),
                              radius: 1.2,
                              colors: [
                                AppColors.white.withValues(
                                  alpha: _shineOpacity,
                                ),
                                AppColors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
