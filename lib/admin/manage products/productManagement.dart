import 'package:ecommerce_app/admin/manage%20products/addProduct.dart';
import 'package:flutter/material.dart';

class ProductManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 248, 208), // Background color of the app bar
        title: Text(
          'Product Management',
          style: TextStyle(color: Color.fromARGB(255, 131, 57, 8),
          fontWeight: FontWeight.bold), // Text color of the app bar title
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 242, 248, 208),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to add product page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 131, 57, 8), // Button color
            ),
            child: Text(
              'Add Product',
              style: TextStyle(color: Colors.white), // Text color of the button
            ),
          ),
        ),
      ),
    );
  }
}
