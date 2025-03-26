import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  
  Product({
    required this.id,
    required this.name,
    required this.price,
  });
  
  // Create a Product from Firestore document data.
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
    );
  }
  
  // Convert Product to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }
}
