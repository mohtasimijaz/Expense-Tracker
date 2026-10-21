import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../utils/app_routes.dart';

/// A rounded panel whose gradient slowly rotates ("breathes") and smoothly
/// blends to a new gradient whenever [gradient] changes — used so the
/// balance card shifts colour with the budget status.
class LivingGradient extends StatefulWidget {
  /// Creates the panel.
  const LivingGradient({
    super.key,
    required this.gradient,
    required this.radius,
    required this.child,
  });

  /// Target gradient (must be a [LinearGradient]).
  final Gradient gradient;
  final double radius;
  final Widget child;

  @override
  State<LivingGradient> createState() => _LivingGradientState();
}

class _LivingGradientState extends State<LivingGradient>
    with SingleTickerProviderStateMixin {
  static const Duration _cycle = Duration(seconds: 16);
  static const Duration _blend = Duration(milliseconds: 900);

  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.enabled(context)) {
      if (!_rotation.isAnimating) _rotation.repeat();
    } else {
      _rotation.stop();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.radius);
    return TweenAnimationBuilder<Gradient?>(
      tween: _GradientTween(end: widget.gradient),
      duration: _blend,
      curve: Curves.easeInOut,
      builder: (context, gradient, child) {
        final linear = gradient is LinearGradient
            ? gradient
            : widget.gradient as LinearGradient;
        return AnimatedBuilder(
          animation: _rotation,
          child: child,
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: linear.begin,
                end: linear.end,
                colors: linear.colors,
                stops: linear.stops,
                transform: GradientRotation(_rotation.value * 2 * pi),
              ),
              boxShadow: [
                BoxShadow(
                  color: linear.colors.first.withValues(
                    alpha: AppEffects.glassBorderOpacity * 1.5,
                  ),
                  blurRadius: AppEffects.shadowBlur,
                  offset: const Offset(0, AppEffects.shadowOffsetY),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _GradientTween extends Tween<Gradient?> {
  _GradientTween({super.end});

  @override
  Gradient? lerp(double t) => Gradient.lerp(begin, end, t);
}
