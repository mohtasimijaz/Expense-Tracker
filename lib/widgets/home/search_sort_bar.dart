import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/expense_sort.dart';
import '../../providers/expense_provider.dart';

/// Search field plus sort and date-range buttons.
class SearchSortBar extends StatefulWidget {
  /// Creates the bar.
  const SearchSortBar({super.key});

  /// Earliest date selectable in the range picker.
  static final DateTime firstSelectableDate = DateTime(2000);

  @override
  State<SearchSortBar> createState() => _SearchSortBarState();
}

class _SearchSortBarState extends State<SearchSortBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ExpenseProvider>().searchQuery,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppDurations.searchDebounce, () {
      if (mounted) context.read<ExpenseProvider>().setSearchQuery(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    context.read<ExpenseProvider>().setSearchQuery('');
  }

  Future<void> _pickDateRange() async {
    final provider = context.read<ExpenseProvider>();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: SearchSortBar.firstSelectableDate,
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: provider.dateRange,
    );
    if (picked != null) provider.setDateRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    final sort = context.select<ExpenseProvider, ExpenseSort>((p) => p.sort);
    final hasRange = context.select<ExpenseProvider, bool>(
      (p) => p.dateRange != null,
    );
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.searchBarHeight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => TextField(
                controller: _controller,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: AppStrings.clearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clear,
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        PopupMenuButton<ExpenseSort>(
          tooltip: AppStrings.sortTooltip,
          initialValue: sort,
          onSelected: context.read<ExpenseProvider>().setSort,
          icon: const Icon(Icons.swap_vert_rounded),
          style: IconButton.styleFrom(backgroundColor: scheme.surface),
          itemBuilder: (context) => [
            for (final option in ExpenseSort.values)
              CheckedPopupMenuItem(
                value: option,
                checked: option == sort,
                child: Text(option.label),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.xxs),
        IconButton(
          tooltip: AppStrings.dateRangeTooltip,
          onPressed: _pickDateRange,
          isSelected: hasRange,
          style: IconButton.styleFrom(
            backgroundColor: hasRange ? scheme.primary : scheme.surface,
            foregroundColor: hasRange ? scheme.onPrimary : null,
          ),
          icon: const Icon(Icons.date_range_rounded),
        ),
      ],
    );
  }
}
