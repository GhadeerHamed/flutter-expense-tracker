import 'package:expense_tracker_project/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker_project/models/expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Flutter Course',
      amount: 19.99,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'Cinema',
      amount: 15.69,
      date: DateTime.now(),
      category: Category.leisure,
    ),
    Expense(
      title: "Lunch",
      amount: 4.5,
      date: DateTime.now(),
      category: Category.food,
    ),
  ];

  _openAddExpenseOverlay() {
    showModalBottomSheet(
      // useSafeArea: true,
      // isScrollControlled: true,
      context: context,
      builder: (ctx) => const Text('Hello World'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
        title: const Text('Expense Tracker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('The chartr'),
          const SizedBox(height: 16),
          Expanded(child: ExpensesList(expenses: _registeredExpenses)),
        ],
      ),
    );
  }
}
