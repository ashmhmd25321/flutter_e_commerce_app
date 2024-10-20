import '../dbConfig/constant.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Order {
  final String productName;
  final double price;
  final String username;
  final DateTime orderedDate;
  final String shippingAddress;
  final String imageUrl; // New field for the product image URL
  final String orderStatus; // New field for the order status

  Order({
    required this.productName,
    required this.price,
    required this.username,
    required this.orderedDate,
    required this.shippingAddress,
    required this.imageUrl, // Add this to the constructor
    required this.orderStatus, // Add this to the constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'price': price,
      'username': username,
      'ordered_date': orderedDate.toIso8601String(),
      'shipping_address': shippingAddress,
      'image_url': imageUrl, // Add to the map
      'order_status': orderStatus, // Add to the map
    };
  }
}

class MongoOrderDatabase {
  static const String collectionName = 'orders';

  static Future<void> saveOrder(Order order) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(collectionName);
    await collection.insert(order.toMap());

    await db.close();
  }
}
