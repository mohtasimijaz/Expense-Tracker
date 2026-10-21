import '../constants/app_strings.dart';
import '../constants/category_data.dart';
import 'expense.dart';

/// Ways the expense list can be ordered.
enum ExpenseSort {
  newestFirst(AppStrings.sortNewest),
  oldestFirst(AppStrings.sortOldest),
  highestAmount(AppStrings.sortHighest),
  lowestAmount(AppStrings.sortLowest),
  category(AppStrings.sortCategory);

  const ExpenseSort(this.label);

  /// Text shown in the sort menu.
  final String label;

  /// Comparator implementing this order. Ties are broken by newest date so
  /// the result is always deterministic.
  int compare(Expense a, Expense b) {
    final byNewest = b.date.compareTo(a.date);
    switch (this) {
      case ExpenseSort.newestFirst:
        return byNewest;
      case ExpenseSort.oldestFirst:
        return a.date.compareTo(b.date);
      case ExpenseSort.highestAmount:
        final result = b.amount.compareTo(a.amount);
        return result != 0 ? result : byNewest;
      case ExpenseSort.lowestAmount:
        final result = a.amount.compareTo(b.amount);
        return result != 0 ? result : byNewest;
      case ExpenseSort.category:
        final result = CategoryData.byId(
          a.category,
        ).label.compareTo(CategoryData.byId(b.category).label);
        return result != 0 ? result : byNewest;
    }
  }
}
