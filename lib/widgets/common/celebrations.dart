import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/budget_status.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/insights_calculator.dart';
import '../../utils/app_haptics.dart';
import '../../utils/formatters.dart';
import 'app_feedback.dart';
import 'confetti.dart';

/// Everything needed after a save, captured before the triggering screen
/// or sheet closes.
class SaveFlowTargets {
  /// Captures navigator and providers from [context].
  SaveFlowTargets.of(BuildContext context)
    : navigator = Navigator.of(context),
      expenses = context.read<ExpenseProvider>(),
      settings = context.read<SettingsProvider>();

  final NavigatorState navigator;
  final ExpenseProvider expenses;
  final SettingsProvider settings;

  bool get _haptics => settings.settings.hapticsEnabled;

  /// This month's budget status right now.
  BudgetStatus budgetStatus() => expenses.budgetStatus(
    limit: settings.settings.monthlyBudget,
    thresholdPercent: settings.settings.alertThresholdPercent,
  );
}

/// Success feedback and celebrations.
abstract final class Celebrations {
  static const String _streakEmoji = '🔥';
  static const String _monthEmoji = '🎉';

  /// After a successful save: green tick, then a budget alert if the level
  /// got worse, then a streak milestone celebration (new expenses only).
  static Future<void> afterSave(
    SaveFlowTargets t, {
    required BudgetStatus before,
    required bool isEdit,
  }) async {
    AppHaptics.playIf(t._haptics, HapticKind.light);
    await AppFeedback.showSuccessOn(
      t.navigator,
      isEdit ? AppStrings.expenseUpdated : AppStrings.expenseSaved,
    );
    if (!t.navigator.mounted) return;
    final after = t.budgetStatus();
    if (t.settings.settings.budgetAlertsEnabled &&
        after.shouldAlertComparedTo(before)) {
      AppHaptics.playIf(t._haptics, HapticKind.heavy);
      await AppFeedback.showBudgetAlert(
        t.navigator.context,
        after,
        t.settings.formatter,
      );
    }
    if (!isEdit && t.navigator.mounted) await _streak(t);
  }

  static Future<void> _streak(SaveFlowTargets t) async {
    final streak = t.expenses.insights.streak();
    final s = t.settings.settings;
    final milestone = InsightsCalculator.milestoneToCelebrate(
      streak,
      celebratedStart: s.celebratedStreakStart,
      celebratedLength: s.celebratedStreakLength,
    );
    final start = streak.start;
    if (milestone == null || start == null) return;
    await t.settings.markStreakCelebrated(start, milestone);
    if (!t.navigator.mounted) return;
    await _show(
      t,
      emoji: _streakEmoji,
      title: AppStrings.streakCelebrationTitle(milestone),
      message: AppStrings.streakCelebrationMessage(milestone),
    );
  }

  /// On app start: celebrates last month if it stayed within budget.
  static Future<void> monthEnd(SaveFlowTargets t) async {
    final s = t.settings.settings;
    final celebration = t.expenses.insights.monthToCelebrate(
      budget: s.monthlyBudget,
      celebratedMonthKey: s.celebratedMonthKey,
    );
    if (celebration == null) return;
    await t.settings.markMonthCelebrated(
      InsightsCalculator.monthKey(celebration.month),
    );
    if (!t.navigator.mounted) return;
    await _show(
      t,
      emoji: _monthEmoji,
      title: AppStrings.monthCelebrationTitle(
        AppDateFormat.monthYear(celebration.month),
      ),
      message: AppStrings.monthCelebrationMessage(
        t.settings.formatter.format(celebration.saved),
      ),
    );
  }

  static Future<void> _show(
    SaveFlowTargets t, {
    required String emoji,
    required String title,
    required String message,
  }) {
    AppHaptics.playIf(t._haptics, HapticKind.heavy);
    final dialog = showDialog<void>(
      context: t.navigator.context,
      builder: (context) => AlertDialog(
        icon: Text(emoji, style: const TextStyle(fontSize: AppSizes.iconHero)),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            ),
            child: const Text(AppStrings.celebrationButton),
          ),
        ],
      ),
    );
    final overlay = t.navigator.overlay;
    if (overlay != null) showConfetti(overlay);
    return dialog;
  }
}
