import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    title: 'Pink Grocery List',
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFFE91E63), // pink theme
      scaffoldBackgroundColor: const Color(0xFFFCE4EC), // soft pink background
      useMaterial3: true,
    ),
    home: const GroceryScreen(),
  ),
);

// Data model: name and price never change, but qty and bought are changeable.
class GroceryItem {
  final String name;
  final double price;
  int qty;
  bool bought;

  GroceryItem({
    required this.name,
    required this.price,
    this.qty = 1,
    this.bought = false,
  });
}

// Stateful because the list changes while the app runs.
class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final List<GroceryItem> _list = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  String? _itemError;
  String? _costError;

  @override
  void initState() {
    super.initState();
    // Preload 3 sample items.
    _list.addAll([
      GroceryItem(name: 'Bread', price: 55.00, qty: 2),
      GroceryItem(name: 'Chicken', price: 180.00, qty: 1),
      GroceryItem(name: 'Coffee', price: 12.00, qty: 6),
    ]);
  }

  @override
  void dispose() {
    _itemController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // Plus button: stops at 99.
  void _addQty(int i) {
    setState(() {
      if (_list[i].qty < 99) _list[i].qty++;
    });
  }

  // Minus button: never goes below 1.
  void _minusQty(int i) {
    setState(() {
      if (_list[i].qty > 1) _list[i].qty--;
    });
  }

  // Checkbox: flip the bought flag.
  void _toggleBought(int i) {
    setState(() {
      _list[i].bought = !_list[i].bought;
    });
  }

  // Sum of price x qty for all items.
  double get _grandTotal {
    double sum = 0;
    for (final item in _list) {
      sum += item.price * item.qty;
    }
    return sum;
  }

  int get _boughtCount => _list.where((item) => item.bought).length;

  // Validate the form; add the item only if both fields are valid.
  void _saveItem() {
    final name = _itemController.text.trim();
    final cost = double.tryParse(_costController.text.trim());

    final itemError = name.isEmpty ? 'Please type an item name' : null;
    final costError = (cost == null || cost <= 0)
        ? 'Price must be more than 0'
        : null;

    setState(() {
      _itemError = itemError;
      _costError = costError;
      if (itemError == null && costError == null) {
        _list.add(GroceryItem(name: name, price: cost!));
        _itemController.clear();
        _costController.clear();
      }
    });
  }

  // Remove every item that is marked as bought.
  void _removeBought() {
    setState(() {
      _list.removeWhere((item) => item.bought);
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
            child: Text('Items: ${_list.length}  |  Bought: $_boughtCount'),
          ),
          Text(
            'Total: PHP ${_grandTotal.toStringAsFixed(2)}',
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
                  controller: _itemController,
                  decoration: InputDecoration(
                    labelText: 'Grocery item',
                    errorText: _itemError,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Cost',
                    errorText: _costError,
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
                  onPressed: _saveItem,
                  child: const Text('Add Item'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _removeBought,
                  child: const Text('Remove bought'),
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
          'Pink Grocery List',
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
                itemCount: _list.length,
                itemBuilder: (context, i) {
                  return GroceryTile(
                    item: _list[i],
                    onAdd: () => _addQty(i),
                    onMinus: () => _minusQty(i),
                    onToggle: () => _toggleBought(i),
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
class GroceryTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onAdd;
  final VoidCallback onMinus;
  final VoidCallback onToggle;

  const GroceryTile({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onMinus,
    required this.onToggle,
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
              value: item.bought,
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
                      decoration: item.bought
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
              onPressed: onMinus,
            ),
            Text(
              '${item.qty}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFFE91E63),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
