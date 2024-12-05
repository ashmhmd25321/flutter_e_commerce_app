import 'package:ecommerce_app/admin/manage%20users/manage_users.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:ecommerce_app/admin/dashboard.dart';
import 'package:ecommerce_app/admin/manage%20products/addProduct.dart';
import 'package:ecommerce_app/admin/manage%20products/productManagement.dart';
import 'package:ecommerce_app/admin/manage%20products/viewProducts.dart';
import 'package:ecommerce_app/users/user.dart';
import 'package:ecommerce_app/users/ViewOrderToUser.dart';
import 'package:ecommerce_app/admin/manage orders/order_management.dart';
import 'package:ecommerce_app/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 131, 57, 8)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => AnimatedSplashScreen(
                duration: 3000,
                splash: Icons.sell_outlined,
                splashTransition: SplashTransition.scaleTransition,
                nextScreen: LoginPage(),
                backgroundColor: const Color.fromARGB(255, 242, 248, 208),
                pageTransitionType: PageTransitionType.fade,
              ),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CustomerHomePage(
                title: 'EzyBuy',
                loggedInUser: args['loggedInUser'],
                userRole: args['userRole'],
                district: args['district'],
              ),
            );

          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterPage());

          case '/admin_dashboard':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (context) => AdminDashboard(
                      title: 'EzyBuy',
                      loggedInUser: args['loggedInUser'],
                      userRole: args['userRole'],
                    ));

          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());

          case '/manageProduct':
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => ProductManagementPage(
                loggedInUser: args['loggedInUser'],
              ),
            );

          case '/addProduct':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (context) => AddProductPage(
                      loggedInUser: args['loggedInUser'],
                    ));

          case '/viewProduct':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (context) => ViewProductsPage(
                      loggedInUser: args['loggedInUser'],
                    ));

          case '/manageUsers':
            return MaterialPageRoute(builder: (context) => ManageUsersPage());

          case '/orders':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ViewOrderToUser(
                loggedInUser: args['loggedInUser'],
              ),
            );

          case '/manageOrders':
            // Get the loggedInUser from the route arguments
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => OrderManagement(
                loggedInUser: args['loggedInUser'],
              ), // Pass the loggedInUser
            );

          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('404 - Not Found')),
                body: const Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}
