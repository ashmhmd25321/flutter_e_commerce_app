import 'dart:async';
import 'package:ecommerce_app/models/Order.dart'; // Import Order model
import 'package:ecommerce_app/dbConfig/mongoDb.dart'; // Import MongoOrderDatabase
import 'package:flutter/material.dart';

class CardPaymentScreen extends StatefulWidget {
  final String productName;
  final double productPrice;
  final String imageUrl;
  final String loggedInUser;

  const CardPaymentScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.imageUrl,
    required this.loggedInUser,
  });

  @override
  _CardPaymentScreenState createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPaymentSuccessful = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  double get totalAmount {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    return quantity * widget.productPrice;
  }

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFF6B4F4F);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for ${widget.productName}'),
        backgroundColor: Color(0xFF6B4F4F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFEFEFEF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Changed to SingleChildScrollView for better scrolling
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align items to the start
            children: [
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
              ] else if (_isPaymentSuccessful) ...[
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 50),
                      SizedBox(height: 20),
                      Text('Payment Successful!',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Back to Home'),
                ),
              ] else ...[
                // Product Info Section
                Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      widget.productName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price per unit: LKR ${widget.productPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.deepOrange),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Amount: LKR ${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange),
                        ),
                      ],
                    ),
                    leading: const Icon(Icons.shopping_cart,
                        color: iconColor, size: 32),
                  ),
                ),
                const SizedBox(height: 20),

                // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Quantity Field
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: const Icon(Icons.format_list_numbered,
                              color: iconColor),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 10),

                      // Username Field
                      TextFormField(
                        controller: _usernameController
                          ..text = widget.loggedInUser,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon:
                              const Icon(Icons.person, color: iconColor),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        keyboardType: TextInputType.text,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Shipping Address Field
                      TextFormField(
                        controller: _shippingAddressController,
                        decoration: InputDecoration(
                          labelText: 'Shipping Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: Icon(Icons.location_on, color: iconColor),
                        ),
                        keyboardType: TextInputType.streetAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your shipping address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Card Number Field
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: Icon(Icons.credit_card, color: iconColor),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 16) {
                            return 'Please enter a valid 16-digit card number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Expiry Date and CVV Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryDateController,
                              decoration: InputDecoration(
                                labelText: 'Expiry Date (MM/YY)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                prefixIcon:
                                    Icon(Icons.date_range, color: iconColor),
                              ),
                              keyboardType: TextInputType.datetime,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter expiry date';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                prefixIcon: Icon(Icons.lock, color: iconColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length != 3) {
                                  return 'Please enter a valid CVV';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Pay Button
                      ElevatedButton(
                        onPressed: _processPayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 155, 64),
                                Color(0xFF6B4F4F),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Center(
                            child: Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate payment processing delay
        await Future.delayed(const Duration(seconds: 2));

        // Create an Order object
        Order order = Order(
          productName: widget.productName,
          price: totalAmount,
          username: _usernameController.text,
          orderedDate: DateTime.now(), // Add the current date
          shippingAddress: _shippingAddressController.text,
          imageUrl: widget.imageUrl, orderStatus: 'Pending',
        );

        // Save the order to the database
        await MongoOrderDatabase.saveOrder(order);

        // Simulate a successful payment
        setState(() {
          _isPaymentSuccessful = true;
        });
      } catch (e) {
        print('Error processing payment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process payment: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
