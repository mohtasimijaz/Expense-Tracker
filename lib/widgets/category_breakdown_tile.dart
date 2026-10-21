import 'package:flutter/material.dart';
import '../constants/category_data.dart';

class CategoryBreakdownTile extends StatelessWidget {
  final String category;
  final double amount;
  final double total;

  const CategoryBreakdownTile({
    super.key,
    required this.category,
    required this.amount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : amount / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                kCategoryIcons[category] ?? Icons.category,
                size: 16,
                color: kCategoryColors[category] ?? Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                'Rs ${amount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                kCategoryColors[category] ?? Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
