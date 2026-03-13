import 'dart:math';

import 'package:expense_tracker_project/models/expense.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final sortedExpenses = [...expenses]
      ..sort((a, b) => a.date.compareTo(b.date));

    final maxAmount = sortedExpenses.isEmpty
        ? 1.0
        : sortedExpenses.map((e) => e.amount).reduce(max).toDouble();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: sortedExpenses.isEmpty
          ? const Center(child: Text('No expenses to chart yet.'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: sortedExpenses
                    .map(
                      (expense) => _ExpenseBar(
                        expense: expense,
                        fill: expense.amount / maxAmount,
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}

class _ExpenseBar extends StatelessWidget {
  const _ExpenseBar({required this.expense, required this.fill});

  final Expense expense;
  final double fill;

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      width: 66,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '\$${expense.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fill.clamp(0.0, 1.0),
                widthFactor: 0.8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    color: isDarkMode
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            expense.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
