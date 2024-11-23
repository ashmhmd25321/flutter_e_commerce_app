import 'package:flutter/material.dart';
import 'package:ecommerce_app/admin/manage%20products/viewProducts.dart';
import '../../Payment/CardPaymentScreen.dart';

class ProductDetailsDialog extends StatelessWidget {
  final Product product;
  final String loggedInUser;

  const ProductDetailsDialog({
    super.key,
    required this.product,
    required this.loggedInUser,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 16,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image with Hero animation for smooth transitions
            Hero(
              tag: product.imageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  product.imageUrl,
                  height: 200.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Product Name
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Product Price
            Text(
              'LKR ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 23, 3, 110),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Product Quantity
            Text(
              product.inStock ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                color: product.inStock ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Product Location
            Text(
              'Location: ${product.location}',
              style: const TextStyle(
                  fontSize: 16.0, color: Color.fromARGB(255, 112, 110, 110)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 37, 16, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                  ),
                  onPressed: () {
                    // Handle payment gateway redirection
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardPaymentScreen(
                          productName: product.name,
                          productPrice: product.price,
                          imageUrl: product.imageUrl,
                          loggedInUser: loggedInUser,
                          sellerName:
                              product.sellerName, // Pass sellerName here
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Buy Now'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
