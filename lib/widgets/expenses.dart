import 'package:expense_tracker_project/widgets/chart/chart.dart';
import 'package:expense_tracker_project/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker_project/models/expense.dart';
import 'package:expense_tracker_project/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import '../db/expense_database.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await ExpenseDatabase.instance.fetchExpenses();
    setState(() {
      _registeredExpenses = expenses;
      _isLoading = false;
    });
  }

  _openAddExpenseOverlay() {
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(maxHeight: screenHeight),
      builder: (ctx) => SizedBox(
        height: screenHeight,
        child: NewExpense(
          onAddExpense: addExpense,
        ),
      ),
    );
  }

  Future<void> addExpense(Expense expense) async {
    await ExpenseDatabase.instance.insertExpense(expense);
    await _loadExpenses();
  }

  Future<void> removeExpense(Expense expense) async {
    await ExpenseDatabase.instance.deleteExpense(expense.id);
    await _loadExpenses();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted.'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ExpenseDatabase.instance.insertExpense(expense);
            await _loadExpenses();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: removeExpense,
      );
    }

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
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registeredExpenses),
                const SizedBox(height: 16),
                Expanded(
                  child: mainContent,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Chart(expenses: _registeredExpenses),
                ),
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
    );
  }
}
