import 'package:ecommerce_app/admin/dashboard.dart';
import 'package:ecommerce_app/admin/manage%20products/addProduct.dart';
import 'package:ecommerce_app/admin/manage%20products/productManagement.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:ecommerce_app/users/user.dart';
import 'package:ecommerce_app/home.dart';
import 'package:ecommerce_app/dbConfig/mongoDb.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 131, 57, 8)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AnimatedSplashScreen(
          duration: 3000,
          splash: Icons.sell_outlined,
          splashTransition: SplashTransition.scaleTransition,
          nextScreen: LoginPage(),
          backgroundColor: const Color.fromARGB(255, 242, 248, 208),
          pageTransitionType: PageTransitionType.fade,
        ),
        '/register': (context) => RegisterPage(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/home': (context) => MyHomePage(title: 'EzyBuy'),
        '/login': (context) => LoginPage(),
        '/manageProduct': (context) => ProductManagementPage(),
        '/addProduct': (context) => AddProductPage(),
      },
    );
  }
}
