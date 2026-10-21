import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../providers/expense_form_controller.dart';
import '../../utils/app_routes.dart';
import '../category_badge.dart';
import 'category_selector.dart';
import 'expense_form_fields.dart';

/// The scrollable add/edit form. Field values live in the controllers
/// passed in; category, date and saving state come from [form].
class ExpenseFormView extends StatelessWidget {
  /// Creates the form view.
  const ExpenseFormView({
    super.key,
    required this.form,
    required this.title,
    required this.amount,
    required this.note,
    required this.currencySymbol,
    required this.decimalDigits,
    required this.isEdit,
    required this.heroTag,
    required this.onSave,
  });

  static const double _slideBegin = 0.1;
  static const double _spinnerStroke = 2;

  final ExpenseFormController form;
  final TextEditingController title;
  final TextEditingController amount;
  final TextEditingController note;
  final String currencySymbol;
  final int decimalDigits;
  final bool isEdit;
  final Object heroTag;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final animate = AppMotion.enabled(context);
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children:
            [
                  Center(
                    child: CategoryIcon(
                      categoryId: form.categoryId,
                      size: AppSizes.logo,
                      heroTag: heroTag,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AmountField(
                    controller: amount,
                    currencySymbol: currencySymbol,
                    decimalDigits: decimalDigits,
                    autofocus: !isEdit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TitleField(controller: title),
                  const FormLabel(AppStrings.fieldCategory),
                  CategorySelector(
                    selectedId: form.categoryId,
                    onSelected: (id) => form.categoryId = id,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DateField(
                    date: form.date,
                    onChanged: (day) => form.day = day,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  NoteField(controller: note),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: form.isSaving ? null : onSave,
                    icon: form.isSaving
                        ? const SizedBox.square(
                            dimension: AppSizes.iconMd,
                            child: CircularProgressIndicator(
                              strokeWidth: _spinnerStroke,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      isEdit
                          ? AppStrings.updateExpense
                          : AppStrings.saveExpense,
                    ),
                  ),
                ]
                .animate(
                  interval: animate
                      ? AppDurations.listItemStagger
                      : Duration.zero,
                )
                .fadeIn(duration: animate ? AppDurations.medium : Duration.zero)
                .slideY(begin: animate ? _slideBegin : 0, end: 0),
      ),
    );
  }
}
