import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_info.dart';
import '../../constants/app_strings.dart';
import '../../models/budget_status.dart';
import '../../utils/formatters.dart';
import 'status_dialog.dart';

/// Snackbars, dialogs and the success animation used across the app.
abstract final class AppFeedback {
  /// Shows a floating snackbar, replacing any visible one.
  static void showSnack(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    showSnackOn(
      messenger,
      message,
      actionLabel: actionLabel,
      onAction: onAction,
      errorColor: isError ? context.palette.danger : null,
    );
  }

  /// Like [showSnack] but on a [messenger] captured earlier — for callers
  /// whose own context may be gone by the time the message is shown (e.g.
  /// a list item that was just swiped away).
  static void showSnackOn(
    ScaffoldMessengerState messenger,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Color? errorColor,
  }) {
    final label = actionLabel;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: AppDurations.snackBar,
          persist: false,

          backgroundColor: errorColor,
          action: label != null && onAction != null
              ? SnackBarAction(label: label, onPressed: onAction)
              : null,
        ),
      );
  }

  /// Plays the green-tick animation with [message] and closes automatically.
  static Future<void> showSuccess(BuildContext context, String message) =>
      showSuccessOn(Navigator.of(context), message);

  /// Like [showSuccess] on a [navigator] captured earlier.
  static Future<void> showSuccessOn(NavigatorState navigator, String message) =>
      showStatusDialog(
        navigator,
        message: message,
        style: const StatusStyle(
          asset: AppAssets.lottieSuccess,
          fallbackIcon: Icons.check_circle_rounded,
        ),
        color: navigator.context.palette.success,
        duration: AppDurations.success,
      );

  /// Plays the red "deleted" bin animation and closes automatically.
  static Future<void> showDeletedOn(NavigatorState navigator, String message) =>
      showStatusDialog(
        navigator,
        message: message,
        style: const StatusStyle(
          asset: AppAssets.lottieDeleted,
          fallbackIcon: Icons.delete_rounded,
        ),
        color: navigator.context.palette.danger,
        duration: AppDurations.deleteFeedback,
      );

  /// Shows a warning or "exceeded" dialog for [status].
  static Future<void> showBudgetAlert(
    BuildContext context,
    BudgetStatus status,
    CurrencyFormatter formatter,
  ) {
    final exceeded = status.level == BudgetLevel.exceeded;
    final palette = context.palette;
    final color = exceeded ? palette.danger : palette.warning;
    final message = exceeded
        ? '${AppStrings.budgetExceededMessage} '
              '${formatter.format(status.overspent)}.'
        : '${AppStrings.budgetWarningMessage} ${status.percentUsed}% '
              '${AppStrings.budgetWarningSuffix}';
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          exceeded ? Icons.error_rounded : Icons.warning_amber_rounded,
          color: color,
          size: AppSizes.iconHero,
        ),
        title: Text(
          exceeded
              ? AppStrings.budgetExceededTitle
              : AppStrings.budgetWarningTitle,
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            ),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  /// Asks the user to confirm a destructive action. Resolves to `true` when
  /// confirmed.
  static Future<bool> confirmDestructive(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final danger = context.palette.danger;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.delete_forever_rounded, color: danger),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: danger,
              minimumSize: const Size(0, AppSizes.chipHeight),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
