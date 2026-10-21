import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_info.dart';
import '../../constants/app_strings.dart';
import '../../models/budget_status.dart';
import '../../utils/app_routes.dart';
import '../../utils/formatters.dart';

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
          backgroundColor: errorColor,
          action: label != null && onAction != null
              ? SnackBarAction(label: label, onPressed: onAction)
              : null,
        ),
      );
  }

  /// Plays the success animation with [message] and closes automatically.
  static Future<void> showSuccess(BuildContext context, String message) async {
    final navigator = Navigator.of(context);
    var closed = false;
    unawaited(
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.black.withValues(alpha: 0.3),
        transitionDuration: AppDurations.medium,
        pageBuilder: (dialogContext, _, _) => _SuccessDialog(message: message),
        transitionBuilder: (context, animation, _, child) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        ),
      ).then((_) => closed = true),
    );
    await Future<void>.delayed(AppDurations.success);
    if (!closed && navigator.mounted) navigator.pop();
  }

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

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: AppSizes.successArt,
                child: Lottie.asset(
                  AppAssets.lottieSuccess,
                  repeat: false,
                  animate: AppMotion.enabled(context),
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.check_circle_rounded,
                    size: AppSizes.iconHero,
                    color: context.palette.success,
                  ),
                ),
              ),
              Text(message, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
