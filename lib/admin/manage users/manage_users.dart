import 'package:ecommerce_app/users/user.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart_query/src/geometry_obj.dart' as mongo_query;

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late Future<List<User>> _usersFuture;
  String _selectedRole = 'All'; // Default to 'All' to show all users

  @override
  void initState() {
    super.initState();
    _usersFuture = MongoDatabase.getAllUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = MongoDatabase.getAllUsers();
    });
  }

  void _filterUsers(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'All') {
        _usersFuture = MongoDatabase.getAllUsers();
      } else {
        _usersFuture = MongoDatabase.getUsersByRole(role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        backgroundColor: const Color(0xFF6B4F4F),
        elevation: 4.0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          DropdownButton<String>(
            value: _selectedRole,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _filterUsers(newValue);
              }
            },
            items: <String>['All', 'Admin', 'Customer']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            icon: const Icon(Icons.filter_list, color: Colors.black),
            underline: Container(),
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading users'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            List<User> users = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  User user = users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: const Color(0xFF6B4F4F),
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Text(
                            'Email: ${user.email}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Role: ${user.userRole}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await MongoDatabase.deleteUserByUsername(
                              user.username);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'User ${user.username} deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _refreshUsers();
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
