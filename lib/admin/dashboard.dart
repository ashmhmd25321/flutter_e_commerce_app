import 'package:ecommerce_app/admin/salesCharts.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _logout() {
    // Add your logout logic here
    Navigator.pushReplacementNamed(
        context, '/login'); // Adjust the route as necessary
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF6B4F4F), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Color(0xFF6B4F4F),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF2F8D0),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF2F8D0).withOpacity(0.9),
              const Color(0xFFE6EBB2).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Sales Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 220, // Increased height for better visibility
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF6B4F4F),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SalesOverviewChart(),
            ),
            const SizedBox(height: 20),
            Expanded(
              // Allow section to fill available space
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildManagementSection('Product Management',
                        Icons.shopping_bag, '/manageProduct'),
                    _buildManagementSection('Order Management',
                        Icons.shopping_cart, '/manageOrders'),
                    _buildManagementSection(
                        'User Management', Icons.person, '/manageUsers'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(String title, IconData icon, String route) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, route);
                },
                icon: Icon(icon),
                label: const Text('Manage'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF6B4F4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(
                      color: Color(0xFF6B4F4F),
                      width: 2.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
