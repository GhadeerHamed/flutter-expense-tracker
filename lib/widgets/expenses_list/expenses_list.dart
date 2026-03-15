import 'package:expense_tracker_project/models/expense.dart';
import 'package:expense_tracker_project/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    required this.scrollController,
    required this.isLoadingMore,
  });

  final List<Expense> expenses;
  final void Function(Expense) onRemoveExpense;
  final ScrollController scrollController;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: expenses.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= expenses.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Dismissible(
          key: ValueKey(expenses[index]),
          onDismissed: (direction) => {
            onRemoveExpense(expenses[index]),
          },
          background: Container(
            color: Theme.of(
              context,
            ).colorScheme.error.withValues(alpha: 0.75),
            margin: EdgeInsets.symmetric(
              horizontal: Theme.of(context).cardTheme.margin!.horizontal,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
          ),
          child: ExpenseItem(expenses[index]),
        );
      },
    );
  }
}
