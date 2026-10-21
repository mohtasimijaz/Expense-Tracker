import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/category_data.dart';
import '../../models/expense.dart';
import '../../providers/quick_add_controller.dart';
import '../../providers/settings_provider.dart';
import '../../screens/add_expense_screen.dart';
import '../../utils/app_haptics.dart';
import '../../utils/app_routes.dart';
import '../common/app_feedback.dart';
import '../common/celebrations.dart';
import 'category_bubbles.dart';
import 'number_pad.dart';
import 'quick_amount_display.dart';

/// Opens the quick-add sheet.
Future<void> showQuickAddSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const QuickAddSheet(),
    );

/// Add an expense in seconds: type the amount on the pad, tap a category,
/// press Save. Title defaults to the category name; "More details" opens
/// the full form with the amount and category carried over.
class QuickAddSheet extends StatefulWidget {
  /// Creates the sheet.
  const QuickAddSheet({super.key});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  late final QuickAddController _controller = QuickAddController(
    decimalDigits: context.read<SettingsProvider>().currency.decimalDigits,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press(PadKey key) {
    if (_controller.press(key)) AppHaptics.play(context, HapticKind.selection);
  }

  void _selectCategory(String id) {
    _controller.categoryId = id;
    AppHaptics.play(context, HapticKind.selection);
  }

  /// Hardware keyboard support (web, desktop, tablets with keyboards).
  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final char = event.character;
    if (key == LogicalKeyboardKey.backspace) {
      _press(PadKey.backspace);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _save();
    } else if (char == '.' || char == ',') {
      _press(PadKey.decimal);
    } else if (char != null && RegExp(r'^\d$').hasMatch(char)) {
      _press(PadKey.forDigit(int.parse(char)));
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Future<void> _save() async {
    if (!_controller.canSave) return;
    final targets = SaveFlowTargets.of(context);
    final before = targets.budgetStatus();
    final category = CategoryData.byId(_controller.categoryId);
    _controller.isSaving = true;
    final ok = await targets.expenses.addExpense(
      Expense(
        id: targets.expenses.newId(),
        title: category.label,
        amount: _controller.amount,
        category: category.id,
        date: DateTime.now(),
      ),
    );
    if (!mounted) return;
    _controller.isSaving = false;
    if (!ok) {
      AppFeedback.showSnack(context, AppStrings.errorSave, isError: true);
      return;
    }
    targets.navigator.pop();
    await Celebrations.afterSave(targets, before: before, isEdit: false);
  }

  void _moreDetails() {
    final navigator = Navigator.of(context);
    final amount = _controller.raw.isEmpty ? null : _controller.amount;
    final categoryId = _controller.categoryId;
    navigator
      ..pop()
      ..push(
        AppRoutes.fadeSlide<void>(
          AddExpenseScreen(initialAmount: amount, initialCategory: categoryId),
          fullscreenDialog: true,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxSheetWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.quickAddTitle,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _moreDetails,
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text(AppStrings.quickAddMoreDetails),
                      ),
                    ],
                  ),
                  QuickAmountDisplay(raw: _controller.raw),
                  const SizedBox(height: AppSpacing.sm),
                  CategoryBubbles(
                    selectedId: _controller.categoryId,
                    onSelected: _selectCategory,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  NumberPad(
                    onKey: _press,
                    onClear: _controller.clear,
                    allowDecimal: _controller.decimalDigits > 0,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FilledButton.icon(
                    onPressed: _controller.canSave ? _save : null,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(AppStrings.quickAddSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
