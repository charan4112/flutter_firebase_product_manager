import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  
  // Controllers for search and filter.
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Returns a filtered stream of products based on search text and price range.
  Stream<List<Product>> getFilteredProducts() {
    return _productService.getProducts().map((products) {
      final searchText = _searchController.text.trim().toLowerCase();
      if (searchText.isNotEmpty) {
        products = products.where((p) => p.name.toLowerCase().contains(searchText)).toList();
      }
      final minPrice = double.tryParse(_minPriceController.text);
      final maxPrice = double.tryParse(_maxPriceController.text);
      if (minPrice != null) {
        products = products.where((p) => p.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((p) => p.price <= maxPrice).toList();
      }
      return products;
    });
  }
  
  // Displays a modal bottom sheet for creating or updating a product.
  Future<void> _createOrUpdate([Product? product]) async {
    final isUpdating = product != null;
    final TextEditingController nameController =
        TextEditingController(text: isUpdating ? product!.name : '');
    final TextEditingController priceController =
        TextEditingController(text: isUpdating ? product!.price.toString() : '');
    
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final price = double.tryParse(priceController.text);
                if (name.isNotEmpty && price != null) {
                  if (isUpdating) {
                    await _productService.updateProduct(
                      Product(id: product!.id, name: name, price: price),
                    );
                  } else {
                    await _productService.addProduct(
                      Product(id: '', name: name, price: price),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(isUpdating ? 'Update' : 'Create'),
            )
          ],
        ),
      ),
    );
  }
  
  Future<void> _deleteProduct(String productId) async {
    await _productService.deleteProduct(productId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Search & Filter UI
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Min Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Max Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() {}),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _minPriceController.clear();
                        _maxPriceController.clear();
                        setState(() {});
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          // Real-time product list.
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: getFilteredProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      final product = products[i];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text('\$${product.price}'),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _createOrUpdate(product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProduct(product.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
