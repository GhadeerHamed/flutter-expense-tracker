import 'dart:math';

import 'package:expense_tracker_project/models/expense.dart';
import 'package:expense_tracker_project/widgets/chart/chart_item_details_screen.dart';
import 'package:flutter/material.dart';

class ExpenseChartGroup {
  const ExpenseChartGroup({
    required this.name,
    required this.total,
    required this.items,
  });

  final String name;
  final double total;
  final List<Expense> items;
}

class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  List<ExpenseChartGroup> get groups {
    final grouped = <String, List<Expense>>{};
    final displayNames = <String, String>{};

    for (final expense in expenses) {
      final normalized = expense.title.trim().toLowerCase();
      grouped.putIfAbsent(normalized, () => []).add(expense);
      displayNames.putIfAbsent(normalized, () => expense.title.trim());
    }

    final result = grouped.entries.map((entry) {
      final items = [...entry.value]..sort((a, b) => b.date.compareTo(a.date));
      final total = items.fold<double>(0, (sum, e) => sum + e.amount);
      return ExpenseChartGroup(
        name: displayNames[entry.key] ?? entry.key,
        total: total,
        items: items,
      );
    }).toList();

    result.sort((a, b) => b.total.compareTo(a.total));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chartGroups = groups;
    final maxAmount = chartGroups.isEmpty
        ? 1.0
        : chartGroups.map((e) => e.total).reduce(max).toDouble();

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
      child: chartGroups.isEmpty
          ? const Center(child: Text('No expenses to chart yet.'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartGroups
                    .map(
                      (group) => _ExpenseBar(
                        group: group,
                        fill: group.total / maxAmount,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ChartItemDetailsScreen(
                                groupName: group.name,
                                items: group.items,
                                total: group.total,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}

class _ExpenseBar extends StatelessWidget {
  const _ExpenseBar({
    required this.group,
    required this.fill,
    required this.onTap,
  });

  final ExpenseChartGroup group;
  final double fill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 82,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '\$${group.total.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: fill.clamp(0.0, 1.0),
                  widthFactor: 0.82,
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
              group.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${group.items.length} items',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
