import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/product_model.dart';

class MenuRepository {
  final FirebaseFirestore _firestore;

  MenuRepository(this._firestore);

  /// Streams products for a specific store
  Stream<List<ProductModel>> getStoreProductsStream(String storeId) {
    return _firestore
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  /// Toggle product availability
  Future<void> toggleProductAvailability(String productId, bool isAvailable) async {
    await _firestore.collection('products').doc(productId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add a new product
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  /// Update an existing product
  Future<void> updateProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).update({
      ...product.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return MenuRepository(firebaseService.firestore);
});

final storeProductsProvider = StreamProvider.family<List<ProductModel>, String>((ref, storeId) {
  final repository = ref.watch(menuRepositoryProvider);
  return repository.getStoreProductsStream(storeId);
});
