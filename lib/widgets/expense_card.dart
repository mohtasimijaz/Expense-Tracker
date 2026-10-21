import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../constants/category_data.dart';
import 'category_badge.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseCard({super.key, required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Category icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (kCategoryColors[expense.category] ?? Colors.grey)
                    .withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                kCategoryIcons[expense.category] ?? Icons.category,
                color: kCategoryColors[expense.category] ?? Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Title and category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CategoryBadge(category: expense.category),
                      const SizedBox(width: 8),
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount and delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs ${expense.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: const Color.fromARGB(255, 28, 220, 50),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
