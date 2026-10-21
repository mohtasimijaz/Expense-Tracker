import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../constants/category_data.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_breakdown_tile.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  String _selectedCategory = 'All';

  final List<Expense> _expenses = [
    Expense(
      id: '1',
      title: 'Lunch at Cafe',
      amount: 450,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 0)),
    ),
    Expense(
      id: '2',
      title: 'Bus Ticket',
      amount: 120,
      category: 'Transport',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Expense(
      id: '3',
      title: 'Flutter Book',
      amount: 800,
      category: 'Education',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Expense(
      id: '4',
      title: 'Grocery Shopping',
      amount: 1200,
      category: 'Shopping',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Expense(
      id: '5',
      title: 'Doctor Visit',
      amount: 500,
      category: 'Health',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Expense(
      id: '6',
      title: 'Movie Tickets',
      amount: 600,
      category: 'Entertainment',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Expense> get _filteredExpenses {
    if (_selectedCategory == 'All') return _expenses;
    return _expenses.where((e) => e.category == _selectedCategory).toList();
  }

  double get _totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);

  double get _filteredTotal =>
      _filteredExpenses.fold(0, (sum, e) => sum + e.amount);

  double get _highestExpense => _expenses.isEmpty
      ? 0
      : _expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

  Map<String, double> get _categoryTotals {
    final Map<String, double> totals = {};
    for (var e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  void _deleteExpense(Expense expense) {
    final index = _expenses.indexOf(expense);
    setState(() {
      _expenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${expense.title}" deleted'),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _expenses.insert(index, expense);
            });
          },
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCat = 'Food';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add New Expense',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Title field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Expense Title',
                      prefixIcon: const Icon(Icons.edit_note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Amount field
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (Rs)',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCat,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: kCategories
                        .where((c) => c != 'All')
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(
                                  kCategoryIcons[c],
                                  size: 18,
                                  color: kCategoryColors[c],
                                ),
                                const SizedBox(width: 8),
                                Text(c),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => selectedCat = val!);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          onPressed: () {
                            final title = titleController.text.trim();
                            final amount = double.tryParse(
                              amountController.text.trim(),
                            );
                            if (title.isEmpty ||
                                amount == null ||
                                amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please enter valid details',
                                  ),
                                  backgroundColor: Colors.red[400],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _expenses.insert(
                                0,
                                Expense(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title: title,
                                  amount: amount,
                                  category: selectedCat,
                                  date: DateTime.now(),
                                ),
                              );
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"$title" added!'),
                                backgroundColor: Colors.green[600],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExpenses;
    final catTotals = _categoryTotals;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistics',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Total: Rs ${_totalExpenses.toStringAsFixed(0)} across ${_expenses.length} expenses',
                  ),
                  backgroundColor: const Color(0xFF6C63FF),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ── Drawer ──────────────────────────────────────────────────────────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFF6C63FF)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'My Expenses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total: Rs ${_totalExpenses.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  'CATEGORY BREAKDOWN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Category breakdown list
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: catTotals.entries.map((entry) {
                    return CategoryBreakdownTile(
                      category: entry.key,
                      amount: entry.value,
                      total: _totalExpenses,
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.red,
                ),
                title: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _expenses.clear());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All expenses cleared'),
                      backgroundColor: Colors.red[400],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: SafeArea(
        child: Column(
          children: [
            // Summary cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SummaryCard(
                    label: 'Total Spent',
                    value: 'Rs ${_totalExpenses.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF6C63FF),
                  ),
                  const SizedBox(width: 10),
                  SummaryCard(
                    label: 'Transactions',
                    value: '${_expenses.length}',
                    icon: Icons.receipt_long,
                    color: const Color(0xFF03DAC6),
                  ),
                  const SizedBox(width: 10),
                  SummaryCard(
                    label: 'Highest',
                    value: 'Rs ${_highestExpense.toStringAsFixed(0)}',
                    icon: Icons.trending_up,
                    color: const Color(0xFFFF6B6B),
                  ),
                ],
              ),
            ),

            // Category filter chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = kCategories[i];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.grey[300]!,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6C63FF,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Expense count header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} expense${filtered.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedCategory != 'All')
                    Text(
                      'Rs ${_filteredTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // Expense list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No expenses found',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: _showAddExpenseDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add one now'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final expense = filtered[i];
                        return ExpenseCard(
                          expense: expense,
                          onDelete: () => _deleteExpense(expense),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
