import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyWorkGraph extends StatelessWidget {
  final List hours;

  const WeeklyWorkGraph({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    final values = hours.map<double>((e) => e["hours"].toDouble()).toList();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                values.length,
                (i) => FlSpot(i.toDouble(), values[i]),
              ),
              isCurved: true,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
