import 'package:expense_tracker_project/models/expense.dart';
import 'package:expense_tracker_project/widgets/chart/chart.dart';
import 'package:flutter/material.dart';

enum DetailSortField { amount, date }

enum DetailSortOrder { ascending, descending }

class ChartItemDetailsScreen extends StatefulWidget {
  const ChartItemDetailsScreen({
    super.key,
    required this.groupName,
    required this.items,
    required this.total,
    required this.groupingMode,
  });

  final String groupName;
  final List<Expense> items;
  final double total;
  final ChartGroupingMode groupingMode;

  @override
  State<ChartItemDetailsScreen> createState() => _ChartItemDetailsScreenState();
}

class _ChartItemDetailsScreenState extends State<ChartItemDetailsScreen> {
  DetailSortField _sortField = DetailSortField.date;
  DetailSortOrder _sortOrder = DetailSortOrder.descending;

  List<Expense> get sortedItems {
    final list = [...widget.items];
    list.sort((a, b) {
      int comparison;
      if (_sortField == DetailSortField.amount) {
        comparison = a.amount.compareTo(b.amount);
      } else {
        comparison = a.date.compareTo(b.date);
      }
      return _sortOrder == DetailSortOrder.ascending ? comparison : -comparison;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'Total: lei ${widget.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${widget.groupingMode.label} - ${sortedItems.length} items',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DetailSortField>(
                    value: _sortField,
                    decoration: const InputDecoration(labelText: 'Sort By'),
                    items: const [
                      DropdownMenuItem(
                        value: DetailSortField.date,
                        child: Text('Date'),
                      ),
                      DropdownMenuItem(
                        value: DetailSortField.amount,
                        child: Text('Amount'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _sortField = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<DetailSortOrder>(
                    value: _sortOrder,
                    decoration: const InputDecoration(labelText: 'Order'),
                    items: const [
                      DropdownMenuItem(
                        value: DetailSortOrder.ascending,
                        child: Text('Ascending'),
                      ),
                      DropdownMenuItem(
                        value: DetailSortOrder.descending,
                        child: Text('Descending'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _sortOrder = value;
                      });
                    },
                  ),
                ),
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
                  trailing: Text('lei ${item.amount.toStringAsFixed(2)}'),
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
