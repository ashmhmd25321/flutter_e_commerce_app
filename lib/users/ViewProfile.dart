import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:ecommerce_app/users/user.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MongoDb {
  static const String collectionName = 'users';

  // Fetch user by username
  static Future<User?> getUserByUsername(String username) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    var user = await collection.findOne(mongo.where.eq('username', username));
    await db.close();

    if (user != null) {
      return User(
        username: user['username'],
        email: user['email'],
        contactNumber: user['contactNumber'],
        address: user['address'],
        password: user['password'],
        userRole: user['userRole'],
      );
    }
    return null;
  }

  // Update user details
  static Future<void> updateUser(String username, String email,
      String contactNumber, String address) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    await collection.updateOne(
      mongo.where.eq('username', username),
      mongo.modify
          .set('email', email)
          .set('contactNumber', contactNumber)
          .set('address', address),
    );
    await db.close();
  }

  // Change user password
  static Future<void> changePassword(
      String username, String newPassword) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    await collection.updateOne(
      mongo.where.eq('username', username),
      mongo.modify.set('password', newPassword),
    );
    await db.close();
  }
}

class ViewProfile extends StatefulWidget {
  final String loggedInUser;

  const ViewProfile({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  User? _user;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user profile on init
  }

  Future<void> _loadUserProfile() async {
    _user = await MongoDb.getUserByUsername(widget.loggedInUser);
    if (_user != null) {
      _emailController.text = _user!.email;
      _contactController.text = _user!.contactNumber;
      _addressController.text = _user!.address;
      setState(() {});
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      await MongoDb.updateUser(
        widget.loggedInUser,
        _emailController.text,
        _contactController.text,
        _addressController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_newPasswordController.text ==
                    _confirmPasswordController.text) {
                  await MongoDb.changePassword(
                      widget.loggedInUser, _newPasswordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password changed successfully!')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match.')),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF6B4F4F),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6B4F4F),
              const Color.fromARGB(255, 228, 220, 213)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _user == null
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Lottie Animation
                          Lottie.asset(
                            'assets/user_profile.json',
                            height: 120,
                            width: 120,
                            repeat: true,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome, ${_user!.username}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                              'Email', _emailController, Icons.email, (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          }),
                          const SizedBox(height: 10),
                          _buildTextField(
                              'Contact Number', _contactController, Icons.phone,
                              (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your contact number';
                            }
                            return null;
                          }),
                          const SizedBox(height: 10),
                          _buildTextField(
                              'Address', _addressController, Icons.location_on,
                              (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          }),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Update Profile'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _showChangePasswordDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Change Password'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String? Function(String?)? validator,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
