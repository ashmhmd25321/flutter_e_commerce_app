import 'package:flutter/material.dart';

class VendorDashboard extends StatefulWidget {
  final String loggedInUser;
  final String district;

  const VendorDashboard({
    super.key,
    required this.loggedInUser,
    required this.district,
  });

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  // Logout method
  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Go to Homepage method with arguments
  void _goToHomepage() {
    Navigator.pushNamed(
      context,
      '/home',
      arguments: {
        'loggedInUser': widget.loggedInUser,
        'district': widget.district, // Pass the logged in user
        'userRole': 'Vendor', // Or pass the actual role here if needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF6B4F4F), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Vendor Dashboard',
                style: TextStyle(
                  color: Color(0xFF6B4F4F),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Hi, ${widget.loggedInUser}', // Display the username here
              style: const TextStyle(
                color: Color(0xFF6B4F4F),
                fontSize: 18,
              ),
            ),
          ],
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
              'Vendor Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildManagementSection(
                      'Manage Products',
                      Icons.shopping_bag,
                      '/manageProduct',
                      widget.loggedInUser,
                    ),
                    _buildManagementSection(
                      'Manage Orders',
                      Icons.shopping_cart,
                      '/manageOrders',
                      widget.loggedInUser,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _goToHomepage,
                        icon: const Icon(Icons.home),
                        label: const Text('Go to Homepage'),
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
            ),
          ],
        ),
      ),
    );
  }

  // Management Section Widget
  Widget _buildManagementSection(
      String title, IconData icon, String route, String username) {
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
                  Navigator.pushNamed(
                    context,
                    route,
                    arguments: {'loggedInUser': username},
                  );
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
