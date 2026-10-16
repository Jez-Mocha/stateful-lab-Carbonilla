import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    title: 'Mini Shopping Cart',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: const CartScreen(),
  ),
);

// Data model: name and price never change, but quantity and gotIt are changeable.
class CartItem {
  final String name;
  final double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

// Stateful because the cart changes while the app runs (quantities, checkboxes, added/removed items).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preload 3 sample items.
    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 12),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  @override
  void dispose() {
    // Free the controllers when the screen is removed.
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shopping Cart')),
      body: ListView(
        children: [
          for (final item in _items)
            ListTile(
              title: Text(item.name),
              subtitle: Text(
                'PHP ${item.price.toStringAsFixed(2)} x ${item.quantity}',
              ),
            ),
        ],
      ),
    );
  }
}
