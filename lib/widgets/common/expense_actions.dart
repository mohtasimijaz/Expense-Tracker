import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../screens/add_expense_screen.dart';
import '../../utils/app_haptics.dart';
import '../../utils/app_routes.dart';
import '../home/expense_options_sheet.dart';
import 'app_feedback.dart';
import 'undo_bar.dart';

/// Everything a delete needs, captured up front because the widget that
/// started it (e.g. a swiped list item) may leave the tree mid-way.
class ExpenseActionTargets {
  /// Captures navigator, messenger, provider and preferences from [context].
  ExpenseActionTargets.of(BuildContext context)
    : navigator = Navigator.of(context),
      messenger = ScaffoldMessenger.of(context),
      provider = context.read<ExpenseProvider>(),
      haptics = AppHaptics.enabledIn(context),
      danger = context.palette.danger;

  final NavigatorState navigator;
  final ScaffoldMessengerState messenger;
  final ExpenseProvider provider;
  final bool haptics;
  final Color danger;
}

/// Shared expense actions: delete (with animation + undo) and the
/// press-and-hold options menu.
abstract final class ExpenseActions {
  /// Deletes [expense], plays the red bin animation, then shows an undo bar
  /// with **UNDO** (restore, with the green tick) and **✕** (make final).
  static Future<void> delete(
    ExpenseActionTargets targets,
    Expense expense,
  ) async {
    final provider = targets.provider;
    final ok = await provider.deleteExpense(expense.id);
    if (!ok) {
      AppFeedback.showSnackOn(
        targets.messenger,
        provider.errorMessage ?? AppStrings.errorDelete,
        errorColor: targets.danger,
      );
      return;
    }
    AppHaptics.playIf(targets.haptics, HapticKind.medium);
    await AppFeedback.showDeletedOn(
      targets.navigator,
      AppStrings.expenseDeletedTitle,
    );
    if (!targets.navigator.mounted) return;
    showUndoBar(
      targets.messenger,
      message: '"${expense.title}" ${AppStrings.expenseDeleted}',
      onUndo: () => _undo(targets),
      onCommit: () => provider.commitDelete(expense.id),
    );
  }

  static Future<void> _undo(ExpenseActionTargets targets) async {
    final ok = await targets.provider.undoDelete();
    if (!ok) {
      AppFeedback.showSnackOn(
        targets.messenger,
        AppStrings.errorRestore,
        errorColor: targets.danger,
      );
      return;
    }
    AppHaptics.playIf(targets.haptics, HapticKind.light);
    if (targets.navigator.mounted) {
      await AppFeedback.showSuccessOn(
        targets.navigator,
        AppStrings.expenseRestored,
      );
    }
  }

  /// Opens the edit screen for [expense].
  static Future<void> edit(BuildContext context, Expense expense) =>
      Navigator.of(
        context,
      ).push(AppRoutes.fadeSlide<void>(AddExpenseScreen(expense: expense)));

  /// Press-and-hold menu with Edit and Delete.
  static Future<void> showOptions(BuildContext context, Expense expense) async {
    AppHaptics.play(context, HapticKind.medium);
    final choice = await showModalBottomSheet<ExpenseOption>(
      context: context,
      showDragHandle: true,
      builder: (_) => ExpenseOptionsSheet(expense: expense),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case ExpenseOption.edit:
        await edit(context, expense);
      case ExpenseOption.delete:
        await delete(ExpenseActionTargets.of(context), expense);
    }
  }
}
