import 'dart:math';

import 'package:expense_tracker_project/models/expense.dart';
import 'package:expense_tracker_project/widgets/chart/chart_item_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ChartGroupingMode { item, day, week, month }

extension ChartGroupingModeLabel on ChartGroupingMode {
  String get label {
    switch (this) {
      case ChartGroupingMode.item:
        return 'Per Item';
      case ChartGroupingMode.day:
        return 'Per Day';
      case ChartGroupingMode.week:
        return 'Per Week';
      case ChartGroupingMode.month:
        return 'Per Month';
    }
  }
}

class ExpenseChartGroup {
  const ExpenseChartGroup({
    required this.key,
    required this.name,
    required this.total,
    required this.items,
  });

  final String key;
  final String name;
  final double total;
  final List<Expense> items;
}

class Chart extends StatefulWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  ChartGroupingMode _groupingMode = ChartGroupingMode.item;

  ({String key, String name}) _groupIdentity(Expense expense) {
    switch (_groupingMode) {
      case ChartGroupingMode.item:
        final normalizedTitle = expense.title.trim().toLowerCase();
        return (
          key: 'item:$normalizedTitle',
          name: expense.title.trim(),
        );
      case ChartGroupingMode.day:
        final day = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        return (
          key: 'day:${DateFormat('yyyy-MM-dd').format(day)}',
          name: DateFormat('dd MMM yyyy').format(day),
        );
      case ChartGroupingMode.week:
        final dayStart = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        final weekStart = dayStart.subtract(
          Duration(days: dayStart.weekday - 1),
        );
        return (
          key: 'week:${DateFormat('yyyy-MM-dd').format(weekStart)}',
          name: 'Week of ${DateFormat('dd MMM').format(weekStart)}',
        );
      case ChartGroupingMode.month:
        final month = DateTime(expense.date.year, expense.date.month);
        return (
          key: 'month:${DateFormat('yyyy-MM').format(month)}',
          name: DateFormat('MMM yyyy').format(month),
        );
    }
  }

  List<ExpenseChartGroup> get groups {
    final grouped = <String, ({String name, List<Expense> items})>{};

    for (final expense in widget.expenses) {
      final identity = _groupIdentity(expense);
      final existing = grouped[identity.key];
      if (existing == null) {
        grouped[identity.key] = (name: identity.name, items: [expense]);
      } else {
        existing.items.add(expense);
      }
    }

    final result = grouped.entries.map((entry) {
      final items = [...entry.value.items]
        ..sort((a, b) => b.date.compareTo(a.date));
      final total = items.fold<double>(0, (sum, e) => sum + e.amount);
      return ExpenseChartGroup(
        key: entry.key,
        name: entry.value.name,
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
      height: 300,
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
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<ChartGroupingMode>(
              value: _groupingMode,
              items: ChartGroupingMode.values
                  .map(
                    (mode) => DropdownMenuItem<ChartGroupingMode>(
                      value: mode,
                      child: Text(mode.label),
                    ),
                  )
                  .toList(),
              onChanged: (mode) {
                if (mode == null) {
                  return;
                }
                setState(() {
                  _groupingMode = mode;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
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
                                      groupingMode: _groupingMode,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
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
