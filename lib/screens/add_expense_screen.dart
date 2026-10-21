import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../models/expense.dart';
import '../providers/expense_form_controller.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/expense_validator.dart';
import '../widgets/add/expense_form_view.dart';
import '../widgets/common/app_feedback.dart';
import '../widgets/expense_card.dart';

/// Full-screen form to add a new expense, or edit [expense] when given.
class AddExpenseScreen extends StatefulWidget {
  /// Creates the screen.
  const AddExpenseScreen({super.key, this.expense});

  /// Hero tag shared with the floating "add" button.
  static const String addHeroTag = 'add-expense-hero';

  /// The expense being edited, or `null` to add a new one.
  final Expense? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ExpenseFormController _form;
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.expense;
    final formatter = context.read<SettingsProvider>().formatter;
    _form = ExpenseFormController(initial: initial);
    _title = TextEditingController(text: initial?.title);
    _amount = TextEditingController(
      text: initial == null ? null : formatter.plain(initial.amount),
    );
    _note = TextEditingController(text: initial?.note);
  }

  @override
  void dispose() {
    _form.dispose();
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_form.isSaving || !(_formKey.currentState?.validate() ?? false)) return;
    final expenses = context.read<ExpenseProvider>();
    final settings = context.read<SettingsProvider>();
    final limits = settings.settings;
    final before = expenses.budgetStatus(
      limit: limits.monthlyBudget,
      thresholdPercent: limits.alertThresholdPercent,
    );
    final expense = Expense(
      id: widget.expense?.id ?? expenses.newId(),
      title: _title.text,
      amount: ExpenseValidator.parseAmount(_amount.text) ?? 0,
      category: _form.categoryId,
      date: _form.date,
      note: _note.text,
    );
    _form.isSaving = true;
    final ok = _isEdit
        ? await expenses.updateExpense(expense)
        : await expenses.addExpense(expense);
    if (!mounted) return;
    _form.isSaving = false;
    if (!ok) {
      AppFeedback.showSnack(
        context,
        expenses.errorMessage ?? AppStrings.errorSave,
        isError: true,
      );
      return;
    }
    await AppFeedback.showSuccess(
      context,
      _isEdit ? AppStrings.expenseUpdated : AppStrings.expenseSaved,
    );
    if (!mounted) return;
    final after = expenses.budgetStatus(
      limit: limits.monthlyBudget,
      thresholdPercent: limits.alertThresholdPercent,
    );
    if (limits.budgetAlertsEnabled && after.shouldAlertComparedTo(before)) {
      await AppFeedback.showBudgetAlert(context, after, settings.formatter);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final expense = widget.expense;
    if (expense == null) return;
    final provider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await provider.deleteExpense(expense.id);
    if (!ok) {
      if (mounted) {
        AppFeedback.showSnack(context, AppStrings.errorDelete, isError: true);
      }
      return;
    }
    navigator.pop();
    AppFeedback.showSnackOn(
      messenger,
      '"${expense.title}" ${AppStrings.expenseDeleted}',
      actionLabel: AppStrings.undo,
      onAction: provider.undoDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.select<SettingsProvider, (String, int)>(
      (s) => (s.currency.symbol, s.currency.decimalDigits),
    );
    final heroTag = _isEdit
        ? ExpenseCard.heroTagFor(widget.expense!.id)
        : AddExpenseScreen.addHeroTag;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? AppStrings.editExpenseTitle : AppStrings.addExpenseTitle,
        ),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: AppStrings.deleteExpense,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Form(
              key: _formKey,
              child: ExpenseFormView(
                form: _form,
                title: _title,
                amount: _amount,
                note: _note,
                currencySymbol: currency.$1,
                decimalDigits: currency.$2,
                isEdit: _isEdit,
                heroTag: heroTag,
                onSave: _save,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
