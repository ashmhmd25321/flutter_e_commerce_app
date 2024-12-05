import 'package:ecommerce_app/admin/manage%20products/viewProducts.dart';
import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:ecommerce_app/Payment/CardPaymentScreen.dart';
import 'package:intl/intl.dart'; // For date formatting

class ProductDetailsDialog extends StatelessWidget {
  final Product product;
  final String loggedInUser;

  const ProductDetailsDialog({
    super.key,
    required this.product,
    required this.loggedInUser,
  });

  Future<List<Map<String, dynamic>>> _fetchReviews(String productId) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection("product_reviews");

    final reviews =
        await collection.find(mongo.where.eq('product_id', productId)).toList();

    await db.close();

    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 16,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        // Make the dialog scrollable
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
              // Product Image
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
              // Buy Now Button
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
                        sellerName: product.sellerName,
                        productId: product.p_id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Buy Now'),
              ),
              const SizedBox(height: 20),
              // Fetch and display reviews
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchReviews(product.p_id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Text('No reviews yet.');
                  } else {
                    final reviews = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Reviews:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...reviews.map((review) {
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      for (int i = 0; i < review['rating']; i++)
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(review['review']),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Reviewed on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(review['review_date']))}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Close button
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
        ),
      ),
    );
  }
}
