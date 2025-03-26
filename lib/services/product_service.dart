import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');
  
  // Returns a stream of Product objects.
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }
  
  // Add a new product.
  Future<void> addProduct(Product product) {
    return _products.add(product.toMap());
  }
  
  // Update an existing product.
  Future<void> updateProduct(Product product) {
    return _products.doc(product.id).update(product.toMap());
  }
  
  // Delete a product by ID.
  Future<void> deleteProduct(String productId) {
    return _products.doc(productId).delete();
  }
}
