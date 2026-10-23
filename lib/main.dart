import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    title: 'Mini Shopping Cart',
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFFE91E63), // pink theme
      scaffoldBackgroundColor: const Color(0xFFFCE4EC), // soft pink background
      useMaterial3: true,
    ),
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

// Stateful because the cart changes while the app runs.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    // Preload 3 sample items.
    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 8),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Plus button: stops at 10.
  void _increase(int i) {
    setState(() {
      if (_items[i].quantity < 10) _items[i].quantity++;
    });
  }

  // Minus button: never goes below 1.
  void _decrease(int i) {
    setState(() {
      if (_items[i].quantity > 1) _items[i].quantity--;
    });
  }

  // Checkbox: flip the gotIt flag.
  void _toggle(int i) {
    setState(() {
      _items[i].gotIt = !_items[i].gotIt;
    });
  }

  void _delete(int i) {
    setState(() {
      _items.removeAt(i);
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

  // Validate the form; add the item only if both fields are valid.
  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    final nameError = name.isEmpty ? 'Please type an item name' : null;
    final priceError =
        (price == null || price.isNaN || price.isInfinite || price <= 0)
        ? 'Price must be more than 0'
        : null;

    setState(() {
      _nameError = nameError;
      _priceError = priceError;
      if (nameError == null && priceError == null) {
        _items.add(CartItem(name: name, price: price!));
        _nameController.clear();
        _priceController.clear();
      }
    });
  }

  // Remove every item that is marked as got it.
  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BBD0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Items: ${_items.length}  |  Got it: $_gotItCount'),
          ),
          Text(
            'Total: PHP ${_total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF880E4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF48FB1), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item name',
                    errorText: _nameError,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    errorText: _priceError,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearChecked,
                  child: const Text('Clear checked'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
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
                    onDelete: () => _delete(i),
                  );
                },
              ),
            ),
            _buildSummary(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }
}

// Stateless because it only displays the item it is given; changes go up through callbacks.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF8BBD0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: item.gotIt,
              activeColor: const Color(0xFFE91E63),
              onChanged: (_) => onToggle(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
              color: const Color(0xFFE91E63),
              onPressed: onDecrease,
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFFE91E63),
              onPressed: onIncrease,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: const Color(
                0xFF880E4F,
              ), // darker pink so it stands apart from +/-
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
