import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';

/// Instagram-style segmented progress: finished segments are full, the
/// current one fills with [progress], later ones are empty.
class StoryProgress extends StatelessWidget {
  /// Creates the bar.
  const StoryProgress({
    super.key,
    required this.count,
    required this.index,
    required this.progress,
  });

  static const double _height = 3;
  static const double _trackOpacity = 0.35;

  final int count;
  final int index;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, _) => LinearProgressIndicator(
                  minHeight: _height,
                  value: i < index
                      ? 1
                      : i == index
                      ? progress.value
                      : 0,
                  color: AppColors.white,
                  backgroundColor: AppColors.white.withValues(
                    alpha: _trackOpacity,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
