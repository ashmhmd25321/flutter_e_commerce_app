import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/Order.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class OrderManagement extends StatefulWidget {
  final String loggedInUser;

  const OrderManagement({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  State<OrderManagement> createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchAllOrders(widget.loggedInUser);
  }

  Future<List<Map<String, dynamic>>> _fetchAllOrders(String username) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    // Get user role based on loggedInUser
    final usersCollection = db.collection('users');
    final user = await usersCollection
        .findOne(mongo.where.eq('username', widget.loggedInUser));
    final userRole = user?['role'] ?? 'Vendor';

    final ordersCollection = db.collection(MongoOrderDatabase.collectionName);

    // Fetch orders based on user role
    List<Map<String, dynamic>> ordersData;
    if (widget.loggedInUser == 'Admin') {
      ordersData = await ordersCollection.find().toList();
    } else {
      ordersData = await ordersCollection
          .find(mongo.where.eq('seller_name', widget.loggedInUser))
          .toList();
    }

    await db.close();
    return ordersData;
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();
    final collection = db.collection(MongoOrderDatabase.collectionName);

    await collection.updateOne(
      mongo.where.eq('_id', mongo.ObjectId.fromHexString(orderId)),
      mongo.modify.set('order_status', newStatus),
    );

    await db.close();
    setState(() {
      _ordersFuture = _fetchAllOrders(widget.loggedInUser);
    });
  }

  void _showStatusUpdateDialog(Map<String, dynamic> order) {
    String selectedStatus = order['order_status'] ?? 'Order Confirmed';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.update, color: Color(0xFF835708)),
              SizedBox(width: 8),
              Text(
                'Update Order Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: _buildDropdownItems(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 10.0),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Select Status',
                      labelStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await _updateOrderStatus(
                    order['_id'].toHexString(), selectedStatus);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF835708),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    const statuses = [
      'Order Confirmed',
      'Order Shipped',
      'Delivered',
      'Canceled',
      'Pending'
    ];
    return statuses
        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: const Color(0xFF6B4F4F),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders available.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(10.0),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              order['image_url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(order['product_name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(
                            'Price: LKR ${order['price'].toStringAsFixed(2)}\nOrdered by: ${order['username']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: _buildStatusBadge(order['order_status']),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Shipping Address:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(order['shipping_address']),
                              const SizedBox(height: 12),
                              Text(
                                'Ordered Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(order['ordered_date']).toLocal())}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => _showStatusUpdateDialog(order),
                            icon: const Icon(Icons.update),
                            label: const Text('Update Status'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),
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

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'order confirmed':
        statusColor = Colors.blue;
        break;
      case 'order shipped':
        statusColor = Colors.purple;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'canceled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
    );
  }
}
