import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_theme.dart';
import '../../utils/expense_validator.dart';
import '../../utils/formatters.dart';
import '../common/pressable_scale.dart';

/// Large amount input with the currency symbol as prefix.
class AmountField extends StatelessWidget {
  /// Creates the field.
  const AmountField({
    super.key,
    required this.controller,
    required this.currencySymbol,
    required this.decimalDigits,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final int decimalDigits;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall?.copyWith(
      fontFeatures: AppTypography.tabularFigures,
    );
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      style: style,
      validator: ExpenseValidator.amount,
      keyboardType: TextInputType.numberWithOptions(decimal: decimalDigits > 0),
      textInputAction: TextInputAction.next,
      inputFormatters: [AmountInputFormatter(decimalDigits: decimalDigits)],
      decoration: InputDecoration(
        labelText: AppStrings.fieldAmount,
        hintText: '0',
        prefixText: '$currencySymbol ',
        prefixStyle: style?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

/// Tappable field showing the selected date; opens a date picker.
class DateField extends StatelessWidget {
  /// Creates the field.
  const DateField({super.key, required this.date, required this.onChanged});

  /// Earliest date the picker allows.
  static final DateTime firstDate = DateTime(2000);

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: date.isAfter(today) ? today : date,
      firstDate: firstDate,
      lastDate: today,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: () => _pick(context),
      semanticLabel: '${AppStrings.fieldDate}: ${AppDateFormat.full(date)}',
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: AppStrings.fieldDate,
          prefixIcon: Icon(Icons.event_rounded),
          suffixIcon: Icon(Icons.expand_more_rounded),
        ),
        child: Text(AppDateFormat.full(date), style: theme.textTheme.bodyLarge),
      ),
    );
  }
}

/// Title field with length limit and validation.
class TitleField extends StatelessWidget {
  /// Creates the field.
  const TitleField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: ExpenseValidator.title,
      maxLength: ExpenseValidator.maxTitleLength,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: AppStrings.fieldTitle,
        hintText: AppStrings.fieldTitleHint,
        prefixIcon: Icon(Icons.edit_note_rounded),
      ),
    );
  }
}

/// Optional multi-line note field.
class NoteField extends StatelessWidget {
  /// Creates the field.
  const NoteField({super.key, required this.controller});

  static const int _maxLines = 3;

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: ExpenseValidator.note,
      maxLength: ExpenseValidator.maxNoteLength,
      maxLines: _maxLines,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: AppStrings.fieldNote,
        hintText: AppStrings.fieldNoteHint,
        prefixIcon: Icon(Icons.sticky_note_2_outlined),
        alignLabelWithHint: true,
      ),
    );
  }
}

/// Label above a form section.
class FormLabel extends StatelessWidget {
  /// Creates a label.
  const FormLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
