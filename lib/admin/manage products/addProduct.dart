import 'dart:io';
import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

  static Future<bool> productIdExists(String pId) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();

    final collection = db.collection(collectionName);
    final existingProduct = await collection.findOne({'product_id': pId});

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
  final String loggedInUser;
  const AddProductPage({super.key, required this.loggedInUser});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController sellerNameController = TextEditingController();
  String? selectedDistrict;
  String? selectedCategory;
  String? selectedSubcategory;
  String? _imagePath;
  bool _isLoading = false;
  bool _inStock = false;

  @override
  void initState() {
    super.initState();
    sellerNameController.text = widget.loggedInUser;
  }

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

  Future<String?> getUserNearestCity() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return "Location permission denied.";
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode to get placemarks (nearby cities)
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        // Attempt to get the nearest city from the locality field
        String? city = placemarks.first.locality;
        if (city != null && city.isNotEmpty) {
          return city; // Return the nearest city if available
        }

        // Fallback to subLocality or subAdministrativeArea if locality is missing
        String? district = placemarks.first.subLocality ??
            placemarks.first.subAdministrativeArea;
        if (district != null && district.isNotEmpty) {
          return district; // Return the district or sub-area name
        }

        // Lastly, fallback to administrativeArea
        return placemarks.first.administrativeArea ??
            "Unable to determine city.";
      } else {
        return "Unable to determine city.";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> _addUserDistrictToList() async {
    // Get the nearest city or district from the user's location
    String? userDistrict = await getUserNearestCity();

    if (userDistrict != null && userDistrict.isNotEmpty) {
      // Check if the district is already in the list
      if (!districts.contains(userDistrict)) {
        setState(() {
          // Add the user's district to the list
          districts.add(userDistrict);
          selectedDistrict = userDistrict; // Optionally set it as selected
        });
      } else {
        // If the district is already in the list, you can show a message or do nothing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your district is already in the list')),
        );
      }
    } else {
      // If location cannot be fetched, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch district from location')),
      );
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
    final pId = productIdController.text;
    final name = productNameController.text;
    final price = double.tryParse(productPriceController.text) ?? 0.0;
    final contactNumber = contactNumberController.text;
    final sellerName = sellerNameController.text;

    if (pId.isNotEmpty &&
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
        final productExists = await MongoDatabase.productIdExists(pId);

        if (!productExists) {
          final imageFile = File(_imagePath!);
          final imageUrl = await _uploadImageToFirebase(imageFile);

          final product = Product(
            id: id,
            p_id: pId,
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
        backgroundColor:
            const Color(0xFF6B4F4F), // A custom color for the app bar
        elevation: 4.0, // Adds shadow for more depth
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product ID
                  _buildInputField(
                    controller: productIdController,
                    label: 'Product ID',
                    icon: Icons.code,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16.0),

                  // Product Name
                  _buildInputField(
                    controller: productNameController,
                    label: 'Product Name',
                    icon: Icons.production_quantity_limits,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16.0),

                  // Price
                  _buildInputField(
                    controller: productPriceController,
                    label: 'Price',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),

                  // Contact Number
                  _buildInputField(
                    controller: contactNumberController,
                    label: 'Contact Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16.0),

                  // Seller Name (Disabled)
                  _buildInputField(
                    controller: sellerNameController,
                    label: 'Seller Name',
                    icon: Icons.person,
                    enabled: false,
                  ),
                  const SizedBox(height: 16.0),

                  // District Dropdown
                  _buildDropdownField(
                    label: 'Location',
                    value: selectedDistrict,
                    items: districts,
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed:
                        _addUserDistrictToList, // Trigger location fetching
                    color: const Color(0xFF6B4F4F),
                  ),
                  const SizedBox(height: 16.0),

                  // Category Dropdown
                  _buildDropdownField(
                    label: 'Category',
                    value: selectedCategory,
                    items: categories,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        selectedSubcategory = null; // Reset subcategory
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Subcategory Dropdown
                  if (selectedCategory != null)
                    _buildDropdownField(
                      label: 'Subcategory',
                      value: selectedSubcategory,
                      items: subcategories[selectedCategory!]!,
                      onChanged: (value) {
                        setState(() {
                          selectedSubcategory = value;
                        });
                      },
                    ),
                  const SizedBox(height: 20),

                  // In Stock Switch
                  _buildInStockSwitch(),
                  const SizedBox(height: 16),

                  // Image Upload Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _getImageFromGallery,
                      icon: const Icon(Icons.image),
                      label: const Text('Upload Image'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF6B4F4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 15.0),
                        elevation: 5.0, // Adds shadow to the button
                      ),
                    ),
                  ),
                  if (_imagePath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_imagePath!)),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Add Product Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProductToDatabase,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF6B4F4F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 8.0, // Adds shadow to the button
                      ),
                      child: const Text(
                        'Add Product',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B4F4F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF6B4F4F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF6B4F4F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF6B4F4F)),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF6B4F4F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF6B4F4F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF6B4F4F)),
        ),
      ),
    );
  }

  Widget _buildInStockSwitch() {
    return Row(
      children: [
        const Text('In Stock:'),
        Switch(
          value: _inStock,
          onChanged: (value) {
            setState(() {
              _inStock = value;
            });
          },
          activeColor: const Color(0xFF6B4F4F),
        ),
      ],
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
      decoration: const InputDecoration(labelText: 'Select District'),
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
      decoration: const InputDecoration(labelText: 'Select Category'),
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
