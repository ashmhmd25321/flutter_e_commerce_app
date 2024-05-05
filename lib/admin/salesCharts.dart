import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SalesOverviewChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data
    final data = [
      SalesData('Jan', 100),
      SalesData('Feb', 200),
      SalesData('Mar', 150),
      SalesData('Apr', 300),
    ];

    // Create a series for the data
    final series = [
      charts.Series(
        id: 'Sales',
        data: data,
        domainFn: (SalesData sales, _) => sales.month,
        measureFn: (SalesData sales, _) => sales.amount,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
            Colors.white), // White color for bars
        labelAccessorFn: (SalesData sales, _) => '${sales.amount}',
      ),
    ];

    // Create a bar chart
    final chart = charts.BarChart(
      series,
      animate: true, // Add animation
    );

    return Container(
      height: 200, // Adjust the height as needed
      padding: EdgeInsets.all(10),
      child: chart,
    );
  }
}

class SalesData {
  final String month;
  final int amount;

  SalesData(this.month, this.amount);
}
