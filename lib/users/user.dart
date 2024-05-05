import 'package:ecommerce_app/dbConfig/constant.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

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

  static Future<bool> loginUser(String username, String password) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(collectionName);

    var user = await collection
        .findOne(where.eq('username', username).eq('password', password));
    await db.close();
    return user != null;
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
      backgroundColor: Color.fromARGB(255, 242, 248, 208), // Background color
      body: Container(
        margin: EdgeInsets.only(top: 50.0), // Add margin to the top of the body
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Sign Up Title
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 131, 57, 8), // Border color
                      width: 2.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(10.0), // Border radius
                  ),
                  padding:
                      const EdgeInsets.all(10.0), // Padding around the text
                  child: const Text(
                    'SIGNUP',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 131, 57, 8),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                // Username TextField
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person,
                        color: Color.fromARGB(255, 131, 57, 8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                // Password TextField
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock,
                        color: const Color.fromARGB(255, 131, 57, 8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10.0),
                // Email TextField
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email,
                        color: Color.fromARGB(255, 131, 57, 8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                // User Role Dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 131, 57, 8), // Border color
                      width: 2.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(10.0), // Border radius
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedUserRole,
                    onChanged: (value) {
                      selectedUserRole = value;
                    },
                    items: ['Admin', 'Customer']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'User Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                // Contact Number TextField
                TextField(
                  controller: contactNumberController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    prefixIcon: Icon(Icons.phone,
                        color: const Color.fromARGB(255, 131, 57, 8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                // Address TextField
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on,
                        color: const Color.fromARGB(255, 131, 57, 8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                // Register Button with increased width
                ElevatedButton(
                  onPressed: () async {
                    if (selectedUserRole == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a user role')),
                      );
                      return;
                    }
                    User user = User(
                      username: usernameController.text,
                      password: passwordController.text,
                      email: emailController.text,
                      userRole: selectedUserRole!,
                      contactNumber: contactNumberController.text,
                      address: addressController.text,
                    );
                    try {
                      await MongoDatabase.registerUser(user);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User registered successfully')),
                      );
                      // Navigate to the login page after successful registration
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Color.fromARGB(255, 131, 57, 8), // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 150,
                        vertical: 15), // Increased button width and height
                    animationDuration:
                        Duration(milliseconds: 500), // Animation duration
                    elevation: 5, // Elevation
                  ),
                  child: Text('Register'),
                ),
                SizedBox(height: 10.0),
                // Login Link
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Color.fromARGB(255, 131, 57, 8),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: <Widget>[
            // Sign In Title
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 131, 57, 8), // Border color
                  width: 2.0, // Border width
                ),
                borderRadius: BorderRadius.circular(10.0), // Border radius
              ),
              padding: const EdgeInsets.all(10.0), // Padding around the text
              child: const Text(
                'SIGNIN',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 131, 57, 8),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            // Username TextField
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon:
                    Icon(Icons.person, color: Color.fromARGB(255, 131, 57, 8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Password TextField
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock,
                    color: const Color.fromARGB(255, 131, 57, 8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            // Login Button with animation and increased width
            ElevatedButton(
              onPressed: () async {
                bool loggedIn = await MongoDatabase.loginUser(
                  usernameController.text,
                  passwordController.text,
                );
                if (loggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login successful')),
                  );
                  // Retrieve user role from the database (You may need to implement this)
                  String userRole =
                      "admin"; // For example, retrieve user role from database
                  // Navigate to different dashboards based on the user role
                  if (userRole == "admin") {
                    Navigator.pushNamed(context, '/admin_dashboard');
                  } else if (userRole == "customer") {
                    Navigator.pushNamed(context, '/home');
                  } else {
                    // Handle other user roles
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid username or password')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromARGB(255, 131, 57, 8), // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 150,
                    vertical: 15), // Increased button width and height
                animationDuration:
                    const Duration(milliseconds: 500), // Animation duration
                elevation: 5, // Elevation
              ),
              child: const Text('Login'),
            ),
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginPage(),
      '/register': (context) => RegisterPage(),
    },
  ));
}
