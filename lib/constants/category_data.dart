import 'package:flutter/material.dart';

const List<String> kCategories = [
  'All',
  'Food',
  'Transport',
  'Shopping',
  'Health',
  'Entertainment',
  'Education',
  'Other',
];

const Map<String, IconData> kCategoryIcons = {
  'Food': Icons.restaurant,
  'Transport': Icons.directions_car,
  'Shopping': Icons.shopping_bag,
  'Health': Icons.local_hospital,
  'Entertainment': Icons.movie,
  'Education': Icons.school,
  'Other': Icons.category,
};

const Map<String, Color> kCategoryColors = {
  'Food': Color(0xFFFF6B6B),
  'Transport': Color(0xFF4ECDC4),
  'Shopping': Color(0xFFFFE66D),
  'Health': Color(0xFF95E1D3),
  'Entertainment': Color(0xFFF38181),
  'Education': Color(0xFFA8D8EA),
  'Other': Color(0xFFAA96DA),
};
