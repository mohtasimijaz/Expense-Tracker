import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../providers/settings_provider.dart';
import '../../utils/expense_validator.dart';
import '../common/app_feedback.dart';

/// Opens the monthly budget dialog and saves the result.
Future<void> showBudgetDialog(BuildContext context) async {
  final settings = context.read<SettingsProvider>();
  final result = await showDialog<double>(
    context: context,
    builder: (_) => BudgetDialog(
      initial: settings.settings.monthlyBudget,
      currencySymbol: settings.currency.symbol,
      decimalDigits: settings.currency.decimalDigits,
      plain: settings.formatter.plain,
    ),
  );
  if (result == null) return;
  final ok = await settings.setMonthlyBudget(result);
  if (!ok && context.mounted) {
    AppFeedback.showSnack(context, AppStrings.errorSettings, isError: true);
  }
}

/// Dialog with a single amount field. Pops with the new budget (`0` to
/// remove) or `null` when cancelled.
class BudgetDialog extends StatefulWidget {
  /// Creates the dialog.
  const BudgetDialog({
    super.key,
    required this.initial,
    required this.currencySymbol,
    required this.decimalDigits,
    required this.plain,
  });

  final double initial;
  final String currencySymbol;
  final int decimalDigits;

  /// Formats [initial] for the text field.
  final String Function(double) plain;

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial > 0 ? widget.plain(widget.initial) : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = ExpenseValidator.parseAmount(text);
    if (parsed == null || parsed < 0) return AppStrings.validationAmountInvalid;
    if (parsed > ExpenseValidator.maxAmount) {
      return AppStrings.validationAmountTooLarge;
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final text = _controller.text.trim();
    Navigator.of(
      context,
    ).pop(text.isEmpty ? 0.0 : ExpenseValidator.parseAmount(text) ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.savings_rounded),
      title: const Text(AppStrings.budgetTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          validator: _validate,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            AmountInputFormatter(decimalDigits: widget.decimalDigits),
          ],
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            prefixText: '${widget.currencySymbol} ',
            hintText: AppStrings.budgetDialogHint,
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        if (widget.initial > 0)
          TextButton(
            onPressed: () => Navigator.of(context).pop(0.0),
            child: const Text(AppStrings.budgetRemove),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, AppSizes.chipHeight),
          ),
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
