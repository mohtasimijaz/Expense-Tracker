import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_theme.dart';

/// Circular budget gauge: an arc that fills as the budget is used, with
/// the percentage in the middle. Drawn in white for the gradient card.
class BudgetRing extends StatelessWidget {
  /// Creates a ring. [progress] is 0..1 (values above 1 show a full ring).
  const BudgetRing({
    super.key,
    required this.progress,
    required this.percent,
    this.size = defaultSize,
  });

  /// Default diameter.
  static const double defaultSize = 84;

  static const double _stroke = 8;

  final double progress;
  final int percent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$percent% ${AppStrings.budgetUsed}',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress.clamp(0, 1).toDouble()),
          duration: AppDurations.slow,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => CustomPaint(
            painter: _RingPainter(value: value, stroke: _stroke),
            child: child,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
                Text(
                  AppStrings.budgetUsed,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.white.withValues(alpha: _labelOpacity),
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const double _labelOpacity = 0.85;
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.stroke});

  static const double _trackOpacity = 0.25;
  static const double _startAngle = -pi / 2;

  final double value;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.white.withValues(alpha: _trackOpacity);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.white;
    canvas.drawArc(arcRect, 0, 2 * pi, false, track);
    if (value > 0) {
      canvas.drawArc(arcRect, _startAngle, 2 * pi * value, false, arc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}
