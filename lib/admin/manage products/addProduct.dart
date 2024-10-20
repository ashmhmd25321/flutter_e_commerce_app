import 'dart:io';
import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart' as path;

class Product {
  final String id;
  final String p_id;
  final String name;
  final double price;
  final String imageUrl;
  final bool inStock;
  final String contactNumber;
  final String location;

  Product({
    required this.id,
    required this.p_id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.inStock,
    required this.contactNumber,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': mongo.ObjectId.parse(id),
      'product_id': p_id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'inStock': inStock,
      'contactNumber': contactNumber,
      'location': location,
    };
  }
}

class MongoDatabase {
  static const String collectionName = 'products';

  static Future<bool> productIdExists(String p_id) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(collectionName);
    final existingProduct = await collection.findOne({'product_id': p_id});

    await db.close();
    return existingProduct != null;
  }

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
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  String? selectedDistrict;
  String? _imagePath;
  bool _isLoading = false;
  bool _inStock = false;

  List<String> districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya'
  ];

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    } else {
      print('No image selected.');
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = path.basename(imageFile.path);
      final imageRef = storageRef.child('images/$fileName');

      final uploadTask = imageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      rethrow;
    }
  }

  Future<void> _saveProductToDatabase() async {
    final p_id = productIdController.text;
    final name = productNameController.text;
    final price = double.tryParse(productPriceController.text) ?? 0.0;
    final contactNumber = contactNumberController.text;

    if (p_id.isNotEmpty &&
        name.isNotEmpty &&
        price > 0 &&
        contactNumber.isNotEmpty &&
        selectedDistrict != null &&
        _imagePath != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final id = mongo.ObjectId().toHexString();
        final productExists = await MongoDatabase.productIdExists(p_id);

        if (!productExists) {
          final imageFile = File(_imagePath!);
          final imageUrl = await _uploadImageToFirebase(imageFile);

          final product = Product(
            id: id,
            p_id: p_id,
            name: name,
            price: price,
            imageUrl: imageUrl,
            inStock: _inStock,
            contactNumber: contactNumber,
            location: selectedDistrict!,
          );
          await MongoDatabase.addProduct(product);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );

          productIdController.clear();
          productNameController.clear();
          productPriceController.clear();
          contactNumberController.clear();
          setState(() {
            _imagePath = null;
            selectedDistrict = null;
            _inStock = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product ID already exists')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: const Color(0xFF6B4F4F), // AppBar color
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                      controller: productIdController, label: 'Product ID'),
                  const SizedBox(height: 20),
                  _buildTextField(
                      controller: productNameController, label: 'Product Name'),
                  const SizedBox(height: 20),
                  _buildTextField(
                      controller: productPriceController,
                      label: 'Price',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _buildTextField(
                      controller: contactNumberController,
                      label: 'Seller Contact Number',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildDistrictDropdown(),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text('In Stock'),
                    value: _inStock,
                    onChanged: (value) {
                      setState(() {
                        _inStock = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _imagePath != null
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_imagePath!),
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 223, 216, 216)),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromARGB(255, 242, 248, 208),
                          ),
                          child: const Center(child: Text('No image selected')),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _getImageFromGallery,
                    icon:
                        const Icon(Icons.image, color: Colors.white, size: 18),
                    label: const Text('Choose Image'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          const Color.fromARGB(255, 131, 57, 8), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      elevation: 4,
                      minimumSize: const Size(140, 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _saveProductToDatabase,
                    icon: const Icon(Icons.add_shopping_cart,
                        color: Colors.white),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      elevation: 4,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Card(
      elevation: 4,
      child: DropdownButtonFormField<String>(
        value: selectedDistrict,
        onChanged: (value) {
          setState(() {
            selectedDistrict = value;
          });
        },
        items: districts.map((district) {
          return DropdownMenuItem(
            value: district,
            child: Text(district),
          );
        }).toList(),
        decoration: const InputDecoration(
          labelText: 'Select District',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
