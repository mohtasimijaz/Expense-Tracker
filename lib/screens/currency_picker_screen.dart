import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../constants/currency_data.dart';
import '../models/app_currency.dart';
import '../providers/settings_provider.dart';
import '../widgets/common/app_feedback.dart';

/// Searchable list of every world currency.
class CurrencyPickerScreen extends StatefulWidget {
  /// Creates the picker.
  const CurrencyPickerScreen({super.key});

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  final ValueNotifier<List<AppCurrency>> _results = ValueNotifier(
    CurrencyData.all,
  );

  @override
  void dispose() {
    _results.dispose();
    super.dispose();
  }

  Future<void> _select(AppCurrency currency) async {
    final ok = await context.read<SettingsProvider>().setCurrency(
      currency.code,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      AppFeedback.showSnack(context, AppStrings.errorSettings, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = context.select<SettingsProvider, String>(
      (s) => s.currency.code,
    );
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.currencyPickerTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextField(
                    autofocus: true,
                    onChanged: (q) => _results.value = CurrencyData.search(q),
                    decoration: const InputDecoration(
                      hintText: AppStrings.currencySearchHint,
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<AppCurrency>>(
                    valueListenable: _results,
                    builder: (context, results, _) {
                      if (results.isEmpty) {
                        return Center(
                          child: Text(
                            AppStrings.currencyNoResults,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.palette.textSecondary,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: results.length,
                        itemExtent: AppSizes.buttonHeight + AppSpacing.md,
                        itemBuilder: (context, index) {
                          final currency = results[index];
                          final isSelected = currency.code == selected;
                          return ListTile(
                            selected: isSelected,
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: AppEffects.tintOpacity),
                              child: FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xxs),
                                  child: Text(
                                    currency.symbol,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(currency.name),
                            subtitle: Text(currency.code),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () => _select(currency),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
