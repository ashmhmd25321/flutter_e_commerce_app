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
  const SalesOverviewChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SalesData>>(
      future: fetchMonthlyOrderData(), // Call the fetch function
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}')); // Handle error
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No data available.')); // Handle empty data
        } else {
          final data = snapshot.data!;

          // Create a series for the data
          final series = [
            charts.Series<SalesData, String>(
              id: 'Orders',
              data: data,
              domainFn: (SalesData sales, _) => sales.month,
              measureFn: (SalesData sales, _) => sales.amount,
              colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                  const Color.fromARGB(
                      255, 192, 195, 197)), // Use blue for bars
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
            padding: const EdgeInsets.all(10),
            child: chart,
          );
        }
      },
    );
  }

  Future<List<SalesData>> fetchMonthlyOrderData() async {
    final db = await mongo.Db.create(
        MONGO_URL); // Replace MONGO_URL with your actual URL
    await db.open();

    final collection = db.collection(MongoOrderDatabase.collectionName);

    // Fetch all orders
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
}
