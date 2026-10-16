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

  // Plus button: stops at 99.
  void _increase(int i) {
    setState(() {
      if (_items[i].quantity < 99) {
        _items[i].quantity++;
      }
    });
  }

  // Minus button: never goes below 1.
  void _decrease(int i) {
    setState(() {
      if (_items[i].quantity > 1) {
        _items[i].quantity--;
      }
    });
  }

  // Checkbox: flip the gotIt flag.
  void _toggle(int i) {
    setState(() {
      _items[i].gotIt = !_items[i].gotIt;
    });
  }

  // Sum of price x quantity for all items.
  double get _total {
    double sum = 0;
    for (final item in _items) {
      sum += item.price * item.quantity;
    }
    return sum;
  }

  int get _gotItCount => _items.where((item) => item.gotIt).length;

  Widget _buildSummaryBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Items: ${_items.length}  •  Got it: $_gotItCount'),
          ),
          Text(
            'Total: PHP ${_total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shopping Cart')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  return CartItemTile(
                    item: _items[i],
                    onIncrease: () => _increase(i),
                    onDecrease: () => _decrease(i),
                    onToggle: () => _toggle(i),
                  );
                },
              ),
            ),
            _buildSummaryBar(),
          ],
        ),
      ),
    );
  }
}

// Stateless because it only displays the item it is given; changes are sent up through callbacks.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Checkbox(value: item.gotIt, onChanged: (_) => onToggle()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // Line-through when the item is checked.
                      decoration: item.gotIt
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    'PHP ${item.price.toStringAsFixed(2)} each',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrease,
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}
