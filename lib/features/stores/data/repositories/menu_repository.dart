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
        .collection('vendors')
        .doc(storeId)
        .collection('foods')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  Future<void> toggleProductAvailability(String storeId, String productId, bool isAvailable) async {
    await _firestore.collection('vendors').doc(storeId).collection('foods').doc(productId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('vendors').doc(product.storeId).collection('foods').add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore.collection('vendors').doc(product.storeId).collection('foods').doc(product.id).update({
      ...product.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String storeId, String productId) async {
    await _firestore.collection('vendors').doc(storeId).collection('foods').doc(productId).delete();
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
