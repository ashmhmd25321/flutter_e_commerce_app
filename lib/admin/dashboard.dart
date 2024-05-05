import 'package:ecommerce_app/admin/salesCharts.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _adminCounter = 0;

  void _incrementAdminCounter() {
    setState(() {
      _adminCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button
        title: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 131, 57, 8), // Border color
              width: 2.0, // Border width
            ),
            borderRadius: BorderRadius.circular(10.0), // Border radius
          ),
          padding: EdgeInsets.all(8.0), // Padding around the text
          child: const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Color.fromARGB(255, 131, 57, 8), // Text color
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 242, 248, 208), // Background color
      ),
      body: Container(
        color: Color.fromARGB(255, 242, 248, 208),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Sales Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200, // Adjust the height as needed
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 131, 57, 8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SalesOverviewChart(), // Display the sales overview chart
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Product Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/manageProduct');
                },
                icon: Icon(Icons.shopping_bag),
                label: Text('Manage Products'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 131, 57, 8), // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0), // Make it more rectangular
                    side: BorderSide(
                      color: Color.fromARGB(255, 131, 57, 8), // Border color
                      width: 2.0, // Border width
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0, // Increase horizontal padding
                    vertical: 20.0, // Increase vertical padding
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Order Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to order management page
                },
                icon: Icon(Icons.shopping_cart),
                label: Text('Manage Orders'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 131, 57, 8), // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0), // Make it more rectangular
                    side: BorderSide(
                      color: Color.fromARGB(255, 131, 57, 8), // Border color
                      width: 2.0, // Border width
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0, // Increase horizontal padding
                    vertical: 20.0, // Increase vertical padding
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'User Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to user management page
                },
                icon: Icon(Icons.person),
                label: Text('Manage Users'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 131, 57, 8), // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0), // Make it more rectangular
                    side: BorderSide(
                      color: Color.fromARGB(255, 131, 57, 8), // Border color
                      width: 2.0, // Border width
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0, // Increase horizontal padding
                    vertical: 20.0, // Increase vertical padding
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
