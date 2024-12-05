import 'package:ecommerce_app/models/Order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../dbConfig/constant.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ViewOrderToUser extends StatefulWidget {
  final String loggedInUser;

  const ViewOrderToUser({super.key, required this.loggedInUser});

  @override
  _ViewOrderToUserState createState() => _ViewOrderToUserState();
}

class _ViewOrderToUserState extends State<ViewOrderToUser> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchUserOrders();
  }

  Future<List<Order>> _fetchUserOrders() async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(MongoOrderDatabase.collectionName);
    final String currentUser = widget.loggedInUser;

    final ordersData =
        await collection.find(mongo.where.eq('username', currentUser)).toList();

    await db.close();

    return ordersData
        .map((order) => Order(
              productId: order['product_id'],
              productName: order['product_name'],
              price: order['price'],
              username: order['username'],
              orderedDate: DateTime.parse(order['ordered_date']),
              shippingAddress: order['shipping_address'],
              imageUrl: order['image_url'],
              orderStatus: order['order_status'],
              sellerName: order['seller_name'],
            ))
        .toList();
  }

  Future<void> _submitReview(String productId, String productName,
      String review, double rating) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection("product_reviews");

    await collection.insertOne({
      'product_id': productId,
      'product_name': productName,
      'review': review,
      'rating': rating, // Save the star rating
      'username': widget.loggedInUser,
      'review_date': DateTime.now().toIso8601String(),
    });

    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFF6B4F4F),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 8,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            order.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 70);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.productName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Seller: ${order.sellerName}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'LKR ${order.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ordered on: ${DateFormat('yyyy-MM-dd').format(order.orderedDate.toLocal())}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Shipping Address: ${order.shippingAddress}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildOrderStatus(order),
                            ],
                          ),
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

  Widget _buildOrderStatus(Order order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.orderStatus) {
      case 'Delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Order Confirmed':
        statusColor = Colors.blue;
        statusIcon = Icons.confirmation_num;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 8),
            Text(
              'Status: ${order.orderStatus}',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (order.orderStatus == 'Delivered')
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4F4F), // Purple shade
              foregroundColor: Colors.white, // Set text color to white
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            onPressed: () =>
                _showReviewDialog(order.productId, order.productName),
            icon: const Icon(Icons.rate_review, size: 20),
            label: const Text('Add Review'),
          ),
      ],
    );
  }

  void _showReviewDialog(String productId, String productName) {
    final _reviewController = TextEditingController();
    double _rating = 0; // Initialize rating

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  hintText: 'Write your review here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Rate this product:'),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating; // Update rating
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final review = _reviewController.text.trim();
                if (review.isNotEmpty && _rating > 0) {
                  await _submitReview(productId, productName, review, _rating);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review submitted!')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
