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
  final String category;
  final String subcategory;
  final String sellerName; // New field

  Product({
    required this.id,
    required this.p_id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.inStock,
    required this.contactNumber,
    required this.location,
    required this.category,
    required this.subcategory,
    required this.sellerName, // Initialize sellerName
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
      'category': category,
      'subcategory': subcategory,
      'sellerName': sellerName, // Map sellerName
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
  final TextEditingController sellerNameController =
      TextEditingController(); // New controller
  String? selectedDistrict;
  String? selectedCategory;
  String? selectedSubcategory;
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

  final List<String> categories = [
    'Electronics',
    'Fashion',
    'Groceries',
    'Home & Kitchen',
    'Health & Beauty',
    'Sports & Outdoors',
    'Toys & Games',
    'Automotive',
    'Books & Media'
  ];

  final Map<String, List<String>> subcategories = {
    'Electronics': [
      'Mobile Phones',
      'Laptops',
      'Cameras',
      'Televisions',
      'Wearable Tech'
    ],
    'Fashion': ['Men', 'Women', 'Kids', 'Footwear', 'Accessories'],
    'Groceries': [
      'Vegetables',
      'Fruits',
      'Beverages',
      'Snacks',
      'Dairy Products'
    ],
    'Home & Kitchen': [
      'Furniture',
      'Kitchen Appliances',
      'Home Decor',
      'Storage',
      'Cleaning Supplies'
    ],
    'Health & Beauty': [
      'Skincare',
      'Makeup',
      'Hair Care',
      'Personal Care',
      'Health Supplements'
    ],
    'Sports & Outdoors': [
      'Fitness Equipment',
      'Outdoor Gear',
      'Sportswear',
      'Camping & Hiking',
      'Cycling'
    ],
    'Toys & Games': [
      'Educational Toys',
      'Board Games',
      'Action Figures',
      'Puzzles',
      'Dolls'
    ],
    'Automotive': [
      'Car Accessories',
      'Motorbike Accessories',
      'Tools & Equipment',
      'Car Electronics'
    ],
    'Books & Media': [
      'Books',
      'Magazines',
      'Music',
      'Movies & TV Shows',
      'Video Games'
    ]
  };

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
    final sellerName = sellerNameController.text; // Get seller name

    if (p_id.isNotEmpty &&
        name.isNotEmpty &&
        price > 0 &&
        contactNumber.isNotEmpty &&
        selectedDistrict != null &&
        selectedCategory != null &&
        selectedSubcategory != null &&
        _imagePath != null &&
        sellerName.isNotEmpty) {
      // Validate seller name
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
            category: selectedCategory!,
            subcategory: selectedSubcategory!,
            sellerName: sellerName, // Pass seller name
          );
          await MongoDatabase.addProduct(product);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );

          productIdController.clear();
          productNameController.clear();
          productPriceController.clear();
          contactNumberController.clear();
          sellerNameController.clear(); // Clear seller name field
          setState(() {
            _imagePath = null;
            selectedDistrict = null;
            selectedCategory = null;
            selectedSubcategory = null;
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
        backgroundColor: const Color(0xFF6B4F4F),
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
                  _buildTextField(
                      controller: sellerNameController,
                      label: 'Seller Name'), // Seller name field
                  const SizedBox(height: 20),
                  _buildDistrictDropdown(),
                  const SizedBox(height: 20),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 20),
                  _buildSubcategoryDropdown(),
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
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProductToDatabase,
                    child: const Text('Save Product'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }

  Widget _buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDistrict,
      onChanged: (value) {
        setState(() {
          selectedDistrict = value;
        });
      },
      items: districts.map((district) {
        return DropdownMenuItem(value: district, child: Text(district));
      }).toList(),
      decoration: InputDecoration(labelText: 'Select District'),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
          selectedSubcategory = null; // Reset subcategory when category changes
        });
      },
      items: categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      decoration: InputDecoration(labelText: 'Select Category'),
    );
  }

  Widget _buildSubcategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedSubcategory,
      onChanged: (value) {
        setState(() {
          selectedSubcategory = value;
        });
      },
      items: (subcategories[selectedCategory] ?? []).map((subcategory) {
        return DropdownMenuItem(value: subcategory, child: Text(subcategory));
      }).toList(),
      decoration: const InputDecoration(labelText: 'Select Subcategory'),
    );
  }
}
