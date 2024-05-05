import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:ecommerce_app/dbConfig/constant.dart';

class Product {
  final String name;
  final double price;
  final String imageUrl;

  Product(this.name, this.price, this.imageUrl);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

class MongoDatabase {
  static const String collectionName = 'products';

  static Future<void> addProduct(Product product) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(collectionName);
    await collection.insert(product.toMap());

    await db.close();
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  String? _imagePath; // Stores the selected image path

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imagePath = pickedFile.path;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 248, 208),
        elevation: 0,
        title: Text(
          'Add Product',
          style: TextStyle(
            color: Color.fromARGB(255, 131, 57, 8),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 242, 248, 208),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: productPriceController,
              decoration: InputDecoration(
                labelText: 'Product Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _imagePath != null
                ? Image.file(
                    File(_imagePath!),
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Placeholder(
                    fallbackHeight: 150,
                    color: const Color.fromARGB(255, 223, 216, 216),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImageFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: Color.fromARGB(255, 131, 57, 8),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image,
                    color: Color.fromARGB(255, 131, 57, 8),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Choose Image',
                    style: TextStyle(
                      color: Color.fromARGB(255, 131, 57, 8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final name = productNameController.text;
                  final price =
                      double.tryParse(productPriceController.text) ?? 0.0;
                  final imageUrl = _imagePath ?? '';

                  if (name.isNotEmpty && price > 0 && imageUrl.isNotEmpty) {
                    final product = Product(name, price, imageUrl);
                    MongoDatabase.addProduct(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Product added successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 131, 57, 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: Text(
                    'Add Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
