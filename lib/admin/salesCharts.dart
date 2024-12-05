import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:ecommerce_app/models/Order.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class SalesData {
  final String month;
  final int amount;

  SalesData(this.month, this.amount);
}

class SalesOverviewChart extends StatelessWidget {
  const SalesOverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SalesData>>(
      future: fetchMonthlyOrderData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        } else {
          final data = snapshot.data!;

          // Create a series for the data
          final series = [
            charts.Series<SalesData, String>(
              id: 'Orders',
              data: data,
              domainFn: (SalesData sales, _) => sales.month,
              measureFn: (SalesData sales, _) => sales.amount,
              colorFn: (SalesData sales, _) {
                // Assign different colors based on the month index
                // Ensure that the index is passed correctly
                final monthIndex = DateTime.parse('${sales.month}-01').month;
                return charts.ColorUtil.fromDartColor(_getBarColor(monthIndex));
              },
              labelAccessorFn: (SalesData sales, _) => '${sales.amount}',
            ),
          ];

          // Create a bar chart with customization
          final chart = charts.BarChart(
            series,
            animate: true,
            animationDuration: const Duration(milliseconds: 800),
            barRendererDecorator: charts.BarLabelDecorator<String>(
              outsideLabelStyleSpec: const charts.TextStyleSpec(
                fontSize: 14,
                color: charts.MaterialPalette.black,
              ),
            ),
            domainAxis: charts.OrdinalAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: const charts.TextStyleSpec(
                  fontSize: 12,
                  color: charts.MaterialPalette.black,
                ),
                labelRotation: 45, // Rotate labels for better visibility
                lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.gray.shadeDefault,
                ),
              ),
            ),
            primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: const charts.TextStyleSpec(
                  fontSize: 12,
                  color: charts.MaterialPalette.black,
                ),
                lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.gray.shadeDefault,
                ),
              ),
            ),
            behaviors: [
              charts.ChartTitle(
                'Monthly Sales Overview',
                behaviorPosition: charts.BehaviorPosition.top,
                titleStyleSpec: const charts.TextStyleSpec(
                  fontSize: 18,
                  color: charts.MaterialPalette.black,
                ),
                titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea,
              ),
            ],
          );

          return Container(
            height: 300, // Increased height for better visibility
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.grey.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Monthly Sales Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4F4F),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: chart),
              ],
            ),
          );
        }
      },
    );
  }

  // Function to fetch monthly order data from MongoDB
  Future<List<SalesData>> fetchMonthlyOrderData() async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(MongoOrderDatabase.collectionName);

    final ordersData = await collection.find().toList();

    await db.close();

    // Create a map to count orders by month
    final Map<String, int> monthlyCounts = {};

    for (var order in ordersData) {
      final orderedDate = DateTime.parse(order['ordered_date']);
      final monthKey =
          '${orderedDate.year}-${orderedDate.month.toString().padLeft(2, '0')}'; // Format YYYY-MM

      monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
    }

    // Convert map to list of SalesData
    return monthlyCounts.entries.map((entry) {
      return SalesData(entry.key, entry.value);
    }).toList();
  }

  // Function to assign colors based on month index
  Color _getBarColor(int monthIndex) {
    const colors = [
      Color.fromARGB(255, 37, 121, 80),
      Color.fromARGB(255, 129, 112, 48),
      Color.fromARGB(255, 151, 42, 42),
      Color.fromARGB(255, 21, 94, 77),
      Color.fromARGB(255, 145, 101, 44),
      Color.fromARGB(255, 121, 25, 57),
      Color.fromARGB(255, 25, 94, 94),
      Color.fromARGB(255, 105, 112, 31),
    ];
    return colors[(monthIndex - 1) % colors.length];
  }
}
