import 'package:ecommerce_app/admin/dashboard.dart';
import 'package:ecommerce_app/admin/manage%20products/ProductReviewsDialog.dart';
import 'package:ecommerce_app/admin/vendorDashboard.dart';
import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:ecommerce_app/users/ViewOrderToUser.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/admin/manage%20products/viewProducts.dart';
import 'admin/manage%20products/ProductDetailsDialog.dart';
import 'users/ViewProfile.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({
    super.key,
    required this.title,
    required this.loggedInUser,
    required this.userRole,
    required this.district,
  });

  final String title;
  final String loggedInUser;
  final String userRole;
  final String district;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<Product>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  String? _selectedLocation;
  String? _selectedCategory;
  String? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts().then((products) {
      setState(() {
        // Default filter for the user's district
        _filteredProducts = products
            .where((product) => product.location == widget.district)
            .toList();
        _selectedLocation = widget.district; // Set initial location filter
      });
      return products;
    });
  }

  // Fetch products from MongoDB
  Future<List<Product>> fetchProducts() async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();
    final productsCollection = db.collection('products');
    final productsList = await productsCollection.find().toList();
    await db.close();

    return productsList.map((productData) {
      return Product.fromMap(
          productData); // Assuming a method to map from Map to Product
    }).toList();
  }

  // Fetch reviews for a specific product
  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    final db = await mongo.Db.create(MONGO_URL);
    await db.open();
    final reviewsCollection = db.collection('product_reviews');
    final reviews =
        await reviewsCollection.find({'product_id': productId}).toList();
    await db.close();
    return reviews;
  }

  void _filterProducts(String query) {
    setState(() {
      _productsFuture.then((products) {
        _filteredProducts = products.where((product) {
          final matchesSearch =
              product.name.toLowerCase().contains(query.toLowerCase());
          final matchesLocation = _selectedLocation == null ||
              product.location == _selectedLocation;
          final matchesCategory = _selectedCategory == null ||
              product.category == _selectedCategory;
          final matchesSubcategory = _selectedSubcategory == null ||
              product.subcategory == _selectedSubcategory;

          return matchesSearch &&
              matchesLocation &&
              matchesCategory &&
              matchesSubcategory;
        }).toList();
      });
    });
  }

  void _onLocationChanged(String? location) {
    setState(() {
      _selectedLocation = location;
      _filterProducts(_searchController.text); // Re-filter with new location
    });
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _filterProducts(_searchController.text); // Re-filter with new category
      _selectedSubcategory = null; // Reset subcategory when category changes
    });
  }

  void _onSubcategoryChanged(String? subcategory) {
    setState(() {
      _selectedSubcategory = subcategory;
      _filterProducts(_searchController.text); // Re-filter with new subcategory
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _showFilterDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter Products',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products available'));
                    } else {
                      final locations = snapshot.data!
                          .map((product) => product.location)
                          .toSet()
                          .toList();
                      final categories = snapshot.data!
                          .map((product) => product.category)
                          .toSet()
                          .toList();

                      return Column(
                        children: [
                          DropdownButton<String?>(
                            value: _selectedLocation,
                            hint: const Text('Select Location'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Locations'),
                              ),
                              ...locations.map((location) {
                                return DropdownMenuItem<String?>(
                                  value: location,
                                  child: Text(location),
                                );
                              }),
                            ],
                            onChanged: _onLocationChanged,
                            isExpanded: true,
                          ),
                          const SizedBox(height: 10),
                          DropdownButton<String?>(
                            value: _selectedCategory,
                            hint: const Text('Select Category'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...categories.map((category) {
                                return DropdownMenuItem<String?>(
                                  value: category,
                                  child: Text(category),
                                );
                              }),
                            ],
                            onChanged: _onCategoryChanged,
                            isExpanded: true,
                          ),
                          const SizedBox(height: 10),
                          if (_selectedCategory != null)
                            FutureBuilder<List<Product>>(
                              future: _productsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('No products available'));
                                } else {
                                  final subcategories = snapshot.data!
                                      .where((product) =>
                                          product.category == _selectedCategory)
                                      .map((product) => product.subcategory)
                                      .toSet()
                                      .toList();

                                  return DropdownButton<String?>(
                                    value: _selectedSubcategory,
                                    hint: const Text('Select Subcategory'),
                                    items: [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('All Subcategories'),
                                      ),
                                      ...subcategories.map((subcategory) {
                                        return DropdownMenuItem<String?>(
                                          value: subcategory,
                                          child: Text(subcategory),
                                        );
                                      }),
                                    ],
                                    onChanged: _onSubcategoryChanged,
                                    isExpanded: true,
                                  );
                                }
                              },
                            ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterProducts("");
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6B4F4F),
          leading: null,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Icon(
                  Icons.person,
                  color: Color.fromARGB(
                      255, 170, 101, 22), // A vibrant color for the icon
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.loggedInUser} - ${widget.district}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewProfile(loggedInUser: widget.loggedInUser),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          elevation: 4.0,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12.0),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF6B4F4F),
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: _filterProducts,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _showFilterDialog,
                    icon: const Icon(
                      Icons.filter_list, // Icon for filtering
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4F4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 14.0),
                      elevation: 6, // Add slight shadow effect
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products available'));
                    } else {
                      final products = _filteredProducts.isEmpty
                          ? snapshot.data!
                          : _filteredProducts;

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return FadeInAnimation(
                            index: index,
                            child: GestureDetector(
                              onTap: () {
                                if (product.inStock) {
                                  // Navigate to product details if the product is in stock
                                  showDialog(
                                    context: context,
                                    builder: (context) => ProductDetailsDialog(
                                      product: product,
                                      loggedInUser: widget.loggedInUser,
                                    ),
                                  );
                                } else {
                                  // Show an alert dialog if the product is out of stock
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Out of Stock'),
                                      content: const Text(
                                        'This product cannot be purchased because it is out of stock.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: const Text('OK'),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ProductReviewsDialog(
                                                  productId: product.id,
                                                  productName: product.name,
                                                ),
                                              );
                                            },
                                            child: const Text('View Reviews'))
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Card(
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(15.0)),
                                        child: Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, _) =>
                                              const Icon(Icons.error,
                                                  size: 100.0),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${product.category} > ${product.subcategory}', // Display category and subcategory
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            product.location,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              product.inStock
                                                  ? 'In Stock'
                                                  : 'Out of Stock',
                                              style: TextStyle(
                                                color: product.inStock
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              'LKR ${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Color(0xFF3A3A3A),
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.userRole == 'Vendor') // Show for Vendor
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorDashboard(
                        loggedInUser: widget.loggedInUser,
                        district: widget.district,
                      ),
                    ),
                  );
                },
                tooltip: 'Go to Vendor Dashboard',
                child: const Icon(Icons.dashboard),
              ),
            if (widget.userRole == 'Admin') // Show for Admin
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminDashboard(
                        loggedInUser: widget.loggedInUser,
                        district: widget.district,
                        title: 'Ezy Buy',
                        userRole: 'Admin',
                      ),
                    ),
                  );
                },
                tooltip: 'Go to Admin Dashboard',
                child: const Icon(Icons.admin_panel_settings),
              ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewOrderToUser(
                      loggedInUser: widget.loggedInUser,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.shopping_cart),
            ),
          ],
        ));
  }
}

class FadeInAnimation extends StatelessWidget {
  final int index;
  final Widget child;

  const FadeInAnimation({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300 + index * 100),
      child: child,
    );
  }
}
