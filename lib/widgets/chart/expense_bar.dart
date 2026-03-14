import 'package:expense_tracker_project/widgets/chart/chart.dart';
import 'package:flutter/material.dart';

class ExpenseBar extends StatelessWidget {
  const ExpenseBar({
    required this.group,
    required this.fill,
    required this.onTap,
    super.key,
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
              'lei ${group.total.toStringAsFixed(0)}',
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
