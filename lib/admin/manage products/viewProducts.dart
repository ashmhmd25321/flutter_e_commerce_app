import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:ecommerce_app/dbConfig/constant.dart';

class Product {
  final String id;
  final String p_id;
  final String name;
  final double price;
  final String imageUrl;
  final bool inStock;
  final String location;
  final String contactNumber;

  Product({
    required this.id,
    required this.p_id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.inStock,
    required this.location,
    required this.contactNumber,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'].toString(),
      p_id: map['product_id'] ?? '',
      name: map['name'] ?? 'Unnamed Product',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      inStock: map['inStock'] ?? false,
      location: map['location'] ?? 'Unknown Location',
      contactNumber: map['contactNumber'] ?? 'No Contact Info',
    );
  }
}

class MongoDatabase {
  static const String collectionName = 'products';

  static Future<List<Product>> getProducts() async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(collectionName);
    final products = await collection.find().toList();
    await db.close();

    return products.map((map) => Product.fromMap(map)).toList();
  }

  static Future<List<Product>> getProductsByLocation(String location) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(collectionName);
    final products =
        await collection.find(mongo.where.eq('location', location)).toList();
    await db.close();

    return products.map((map) => Product.fromMap(map)).toList();
  }

  static Future<void> updateProductStock(String pId, bool inStock) async {
    try {
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();

      final collection = db.collection(collectionName);
      await collection.update(
        mongo.where.eq('product_id', pId),
        mongo.modify.set('inStock', inStock),
      );

      await db.close();
    } catch (e) {
      print('Error updating product stock: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(String pId) async {
    try {
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();

      final collection = db.collection(collectionName);
      await collection.remove(mongo.where.eq('product_id', pId));

      await db.close();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}

class ViewProductsPage extends StatefulWidget {
  @override
  _ViewProductsPageState createState() => _ViewProductsPageState();
}

class _ViewProductsPageState extends State<ViewProductsPage> {
  Future<void> _deleteProduct(String pId) async {
    try {
      await MongoDatabase.deleteProduct(pId);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  Future<void> _editProductStock(Product product) async {
    bool? newStock = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Stock Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Is the product in stock?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // In Stock
                    },
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Out of Stock
                    },
                    child: const Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (newStock != null && newStock != product.inStock) {
      await MongoDatabase.updateProductStock(product.p_id, newStock);
      setState(() {}); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product stock updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B4F4F),
        title: const Text(
          'View Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: MongoDatabase.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator();
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 80);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'LKR ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'In Stock: ${product.inStock ? 'Yes' : 'No'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Location: ${product.location}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Seller Contact: ${product.contactNumber}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editProductStock(product);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, product.p_id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String pId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(pId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}