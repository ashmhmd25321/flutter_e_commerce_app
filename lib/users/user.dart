import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../admin/manage users/manage_users.dart';

class User {
  String username;
  String password;
  String email;
  String userRole;
  String contactNumber;
  String address;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.userRole,
    required this.contactNumber,
    required this.address,
  });
}

class MongoDatabase {
  static const String collectionName = 'users';

  static Future<User?> getUserByUsername(String username) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    var user = await collection.findOne(where.eq('username', username));
    await db.close();

    if (user != null) {
      return User(
        username: user['username'],
        password: user['password'],
        email: user['email'],
        userRole: user['userRole'],
        contactNumber: user['contactNumber'],
        address: user['address'],
      );
    }
    return null;
  }

  static Future<List<User>> getUsersByRole(String role) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    var users = await collection.find(where.eq('userRole', role)).toList();
    await db.close();

    return users.map((user) {
      return User(
        username: user['username'],
        password: user['password'],
        email: user['email'],
        userRole: user['userRole'],
        contactNumber: user['contactNumber'],
        address: user['address'],
      );
    }).toList();
  }

  static Future<void> deleteUserByUsername(String username) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    await collection.remove(where.eq('username', username));
    await db.close();
  }

  static Future<List<User>> getAllUsers() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    var users = await collection.find().toList();
    await db.close();

    return users.map((user) {
      return User(
        username: user['username'],
        password: user['password'],
        email: user['email'],
        userRole: user['userRole'],
        contactNumber: user['contactNumber'],
        address: user['address'],
      );
    }).toList();
  }

  static Future<void> registerUser(User user) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    var existingUser = await collection.findOne(
        where.eq('username', user.username).or(where.eq('email', user.email)));
    if (existingUser != null) {
      throw Exception('Username or email already exists');
    }

    await collection.insertOne({
      'username': user.username,
      'password': user.password,
      'email': user.email,
      'userRole': user.userRole,
      'contactNumber': user.contactNumber,
      'address': user.address,
    });
    await db.close();
  }

  static Future<User?> loginUser(String username, String password) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    var user = await collection.findOne(
      where.eq('username', username).eq('password', password),
    );
    await db.close();

    if (user != null) {
      return User(
        username: user['username'],
        password: user['password'],
        email: user['email'],
        userRole: user['userRole'],
        contactNumber: user['contactNumber'],
        address: user['address'],
      );
    }
    return null;
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedUserRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 248, 208),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation at the top
              Lottie.asset(
                'assets/signUp_anuimation.json',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              // Title
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign up to get started!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Username Field
              _buildTextField(
                controller: usernameController,
                labelText: 'Username',
                icon: Icons.person,
              ),
              const SizedBox(height: 10),
              // Password Field
              _buildTextField(
                controller: passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              // Email Field
              _buildTextField(
                controller: emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 10),
              // Role Dropdown
              _buildDropdownField(),
              const SizedBox(height: 10),
              // Contact Number Field
              _buildTextField(
                controller: contactNumberController,
                labelText: 'Contact Number',
                icon: Icons.phone,
              ),
              const SizedBox(height: 10),
              // Address Field
              _buildTextField(
                controller: addressController,
                labelText: 'Address',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 20),
              // Register Button with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedUserRole == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select a user role')),
                      );
                      return;
                    }

                    // User Registration Logic
                    try {
                      final newUser = User(
                        username: usernameController.text,
                        password: passwordController.text,
                        email: emailController.text,
                        userRole: selectedUserRole!,
                        contactNumber: contactNumberController.text,
                        address: addressController.text,
                      );

                      // Attempt to register the user in MongoDB
                      await MongoDatabase.registerUser(newUser);

                      // Show success message only if registration succeeds
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('User registered successfully!')),
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      // Display error message if registration fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Registration failed: ${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4F4F), // Purple shade
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Already have an account? Login
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: Color(0xFF6B4F4F),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Color(0xFF6B4F4F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  // Dropdown Field for User Role
  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF6A1B9A)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedUserRole,
        onChanged: (value) {
          selectedUserRole = value;
        },
        items: ['Vendor', 'Customer']
            .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
            .toList(),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'User Role',
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 248, 208), // Background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50.0), // Top margin

              // Lottie Animation
              Lottie.asset(
                'assets/login_animation.json',
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 20.0),

              // Sign In Title
              _buildTitle(),
              const SizedBox(height: 24.0),

              // Username TextField
              _buildTextField(
                usernameController,
                'Username',
                Icons.person,
              ),
              const SizedBox(height: 20.0),

              // Password TextField
              _buildTextField(
                passwordController,
                'Password',
                Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 20.0),

              // Login Button
              _buildLoginButton(context),
              const SizedBox(height: 10.0),

              // Register Button
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 131, 57, 8),
                ),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF6B4F4F), width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10.0),
      child: const Text(
        'SIGN IN',
        style: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B4F4F),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Color(0xFF6B4F4F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        User? user = await MongoDatabase.loginUser(
          usernameController.text,
          passwordController.text,
        );

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful')),
          );

          // Navigate to the correct dashboard with user ID
          if (user.userRole == "Admin") {
            Navigator.pushReplacementNamed(
              context,
              '/admin_dashboard',
              arguments: {
                'loggedInUser': usernameController.text,
                'userRole': user.userRole,
              },
            );
          } else if (user.userRole == "Customer") {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: {
                'loggedInUser': usernameController.text,
                'userRole': user.userRole,
              },
            );
          } else if (user.userRole == "Vendor") {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: {
                'loggedInUser': usernameController.text,
                'userRole': user.userRole,
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF6B4F4F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
        animationDuration: const Duration(milliseconds: 500),
        elevation: 5,
      ),
      child: const Text(
        'Login',
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginPage(),
      '/register': (context) => RegisterPage(),
      '/manage_users': (context) => ManageUsersPage(),
    },
  ));
}
