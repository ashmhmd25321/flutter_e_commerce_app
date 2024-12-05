import '../dbConfig/constant.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Order {
  final String productId;
  final String productName;
  final double price;
  final String username;
  final DateTime orderedDate;
  final String shippingAddress;
  final String imageUrl;
  final String orderStatus;
  final String sellerName; // New seller name field

  Order({
    required this.productId,
    required this.productName,
    required this.price,
    required this.username,
    required this.orderedDate,
    required this.shippingAddress,
    required this.imageUrl,
    required this.orderStatus,
    required this.sellerName, // Add it to the constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'username': username,
      'ordered_date': orderedDate.toIso8601String(),
      'shipping_address': shippingAddress,
      'image_url': imageUrl,
      'order_status': orderStatus,
      'seller_name': sellerName,
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
