import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Review {
  final String username;
  final double rating;
  final String reviewText;
  final DateTime reviewDate;

  Review({
    required this.username,
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      username: map['username'] ?? 'Anonymous',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewText: map['reviewText'] ?? '',
      reviewDate:
          DateTime.parse(map['reviewDate'] ?? DateTime.now().toString()),
    );
  }
}

class MongoDatabase {
  static const String reviewCollectionName = 'product_reviews';

  static Future<List<Review>> getReviewsByProductId(String productId) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(reviewCollectionName);
    final reviews =
        await collection.find(mongo.where.eq('productId', productId)).toList();
    await db.close();

    return reviews.map((map) => Review.fromMap(map)).toList();
  }
}
