import 'package:flutter/material.dart';
import 'package:ecommerce_app/admin/manage%20products/addProduct.dart';
import 'package:ecommerce_app/admin/manage%20products/viewProducts.dart';

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 248, 208),
        title: const Text(
          'Product Management',
          style: TextStyle(
            color: Color(0xFF6B4F4F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 242, 248, 208).withOpacity(0.9),
              const Color.fromARGB(255, 226, 235, 178).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildManagementButton(
                context,
                'Add Product',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductPage()),
                  );
                },
              ),
              const SizedBox(height: 20), // Add spacing between the buttons
              _buildManagementButton(
                context,
                'View Products',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewProductsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementButton(
      BuildContext context, String title, VoidCallback onPressed) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: double.infinity, // Make the button fill available width
        height: 60, // Set a fixed height for the buttons
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B4F4F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18, // Increased font size for better readability
            ),
          ),
        ),
      ),
    );
  }
}
