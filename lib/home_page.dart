import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  // Controllers for CRUD operations
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Controllers for search and filter functionality
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  Future<void> _createOrUpdate([DocumentSnapshot? doc]) async {
    String action = 'create';
    if (doc != null) {
      action = 'update';
      _nameController.text = doc['name'];
      _priceController.text = doc['price'].toString();
    }

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
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text;
                final price = double.tryParse(_priceController.text);

                if (name.isNotEmpty && price != null) {
                  if (action == 'create') {
                    await _products.add({'name': name, 'price': price});
                  } else {
                    await _products.doc(doc!.id).update({
                      'name': name,
                      'price': price,
                    });
                  }
                  _nameController.clear();
                  _priceController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text(action == 'create' ? 'Create' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    await _products.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted')),
    );
  }

  // Method to filter products based on search text and price range
  Stream<QuerySnapshot> _filteredProductsStream() {
    Query query = _products;

    final name = _searchController.text.trim();
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    if (name.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff');
    }

    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Manager')),
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
          // Real-time Firestore Product List
          Expanded(
            child: StreamBuilder(
              stream: _filteredProductsStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(doc['name']),
                          subtitle: Text('\$${doc['price']}'),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _createOrUpdate(doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProduct(doc.id),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
