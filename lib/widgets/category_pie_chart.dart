import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, int> categoryCount;

  const CategoryPieChart({super.key, required this.categoryCount});

  @override
  Widget build(BuildContext context) {
    final total = categoryCount.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return const Center(child: Text("No data"));
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    int i = 0;

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 40,
        sections: categoryCount.entries.map((entry) {
          final value = entry.value;
          final percent = (value / total * 100).toStringAsFixed(1);

          return PieChartSectionData(
            color: colors[i++ % colors.length],
            value: value.toDouble(),
            title: "$percent%",
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
