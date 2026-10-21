import 'package:flutter/material.dart';
import '../constants/category_data.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (kCategoryColors[category] ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            kCategoryIcons[category] ?? Icons.category,
            size: 12,
            color: kCategoryColors[category] ?? Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kCategoryColors[category] ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
