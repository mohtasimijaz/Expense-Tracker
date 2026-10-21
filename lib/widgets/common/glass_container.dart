import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';

/// Frosted-glass panel: blurred backdrop, translucent tint and a soft
/// highlight border.
class GlassContainer extends StatelessWidget {
  /// Creates a glass panel.
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.xl,
    this.opacity = AppEffects.glassOpacity,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  /// Tint opacity (0..1).
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tint = context.palette.glassTint;
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppEffects.glassBlur,
          sigmaY: AppEffects.glassBlur,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: tint.withValues(alpha: opacity),
            border: Border.all(
              color: tint.withValues(alpha: AppEffects.glassBorderOpacity),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
