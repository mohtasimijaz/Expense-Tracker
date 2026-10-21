import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../providers/expense_provider.dart';
import '../../utils/app_routes.dart';

/// "🔥 5-day streak" pill shown when expenses were logged on 2+ days in a
/// row (ending today or yesterday).
class StreakChip extends StatelessWidget {
  /// Creates the chip.
  const StreakChip({super.key});

  static const int _minDays = 2;
  static const String _fire = '🔥';

  @override
  Widget build(BuildContext context) {
    final days = context.select<ExpenseProvider, int>(
      (p) => p.insights.streak().length,
    );
    if (days < _minDays) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final color = context.palette.warning;
    final chip = Tooltip(
      message: AppStrings.streakTooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: AppEffects.tintOpacity),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: color.withValues(alpha: AppEffects.glassBorderOpacity),
          ),
        ),
        child: Text(
          '$_fire ${AppStrings.streakChip(days)}',
          style: theme.textTheme.labelLarge?.copyWith(color: color),
        ),
      ),
    );
    if (!AppMotion.enabled(context)) return chip;
    return chip
        .animate(key: ValueKey(days))
        .scale(
          begin: const Offset(0.8, 0.8),
          curve: Curves.easeOutBack,
          duration: AppDurations.slow,
        );
  }
}
