import 'package:expense_tracker_project/models/expense.dart';
import 'package:flutter/material.dart';

class ChartItemDetailsScreen extends StatelessWidget {
  const ChartItemDetailsScreen({
    super.key,
    required this.groupName,
    required this.items,
    required this.total,
  });

  final String groupName;
  final List<Expense> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${sortedItems.length} items'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: sortedItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final item = sortedItems[index];
                return ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(item.title),
                  subtitle: Text(item.formattedDate),
                  trailing: Text('\$${item.amount.toStringAsFixed(2)}'),
                  tileColor: index.isEven
                      ? Colors.grey.withValues(alpha: .3)
                      : Colors.transparent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
