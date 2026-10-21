import 'package:flutter/material.dart';

/// A spending category with its icon and theme-aware colors.
@immutable
class ExpenseCategory {
  /// Creates a category. [id] is what gets stored in the database.
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.lightColor,
    required this.darkColor,
  });

  /// Stable identifier persisted with each expense. Never change it.
  final String id;

  /// Human-readable name.
  final String label;

  final IconData icon;

  /// Color used on light backgrounds (meets 3:1 against white for icons).
  final Color lightColor;

  /// Lighter variant used on dark backgrounds.
  final Color darkColor;

  /// Picks the right color for [brightness].
  Color colorFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkColor : lightColor;
}

/// All categories available in the app.
abstract final class CategoryData {
  static const ExpenseCategory food = ExpenseCategory(
    id: 'Food',
    label: 'Food',
    icon: Icons.restaurant_rounded,
    lightColor: Color(0xFFE11D48),
    darkColor: Color(0xFFFB7185),
  );
  static const ExpenseCategory transport = ExpenseCategory(
    id: 'Transport',
    label: 'Transport',
    icon: Icons.directions_car_rounded,
    lightColor: Color(0xFF0891B2),
    darkColor: Color(0xFF22D3EE),
  );
  static const ExpenseCategory shopping = ExpenseCategory(
    id: 'Shopping',
    label: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    lightColor: Color(0xFFD97706),
    darkColor: Color(0xFFFBBF24),
  );
  static const ExpenseCategory health = ExpenseCategory(
    id: 'Health',
    label: 'Health',
    icon: Icons.local_hospital_rounded,
    lightColor: Color(0xFF059669),
    darkColor: Color(0xFF34D399),
  );
  static const ExpenseCategory entertainment = ExpenseCategory(
    id: 'Entertainment',
    label: 'Entertainment',
    icon: Icons.movie_rounded,
    lightColor: Color(0xFF9333EA),
    darkColor: Color(0xFFC084FC),
  );
  static const ExpenseCategory education = ExpenseCategory(
    id: 'Education',
    label: 'Education',
    icon: Icons.school_rounded,
    lightColor: Color(0xFF2563EB),
    darkColor: Color(0xFF60A5FA),
  );
  static const ExpenseCategory other = ExpenseCategory(
    id: 'Other',
    label: 'Other',
    icon: Icons.category_rounded,
    lightColor: Color(0xFF64748B),
    darkColor: Color(0xFF94A3B8),
  );

  /// Categories in display order.
  static const List<ExpenseCategory> all = [
    food,
    transport,
    shopping,
    health,
    entertainment,
    education,
    other,
  ];

  /// Default category for new expenses.
  static const ExpenseCategory defaultCategory = food;

  static final Map<String, ExpenseCategory> _byId = {
    for (final category in all) category.id: category,
  };

  /// Looks up a category by [id], falling back to [other] for unknown ids
  /// so old or corrupted data never crashes the UI.
  static ExpenseCategory byId(String id) => _byId[id] ?? other;

  /// Whether [id] is a known category.
  static bool isValid(String id) => _byId.containsKey(id);
}
