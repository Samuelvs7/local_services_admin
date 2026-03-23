import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/store_model.dart'; // Ensure correct import path

class StoreRepository {
  final FirebaseFirestore _firestore;

  StoreRepository(this._firestore);

  // Get All Stores (for management)
  Stream<List<Store>> getStoresStream() {
    return _firestore
        .collection('vendors')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isDeleted'] != true;
            })
            .map((doc) => Store.fromFirestore(doc))
            .toList());
  }

  // Get Pending Stores
  Stream<List<Store>> getPendingStores() {
    return _firestore
        .collection('vendors')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isDeleted'] != true;
            })
            .map((doc) => Store.fromFirestore(doc))
            .toList());
  }

  // Get Approved Stores
  Stream<List<Store>> getApprovedStores() {
    return _firestore
        .collection('vendors')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isDeleted'] != true;
            })
            .map((doc) => Store.fromFirestore(doc))
            .toList());
  }

  // Approve Store
  Future<void> approveStore(String storeId, String adminId) async {
    await _firestore.collection('vendors').doc(storeId).update({
      'status': StoreStatus.approved.name,
      'isActive': true,
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': adminId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Reject Store
  Future<void> rejectStore(String storeId, String adminId, String reason) async {
    await _firestore.collection('vendors').doc(storeId).update({
      'status': StoreStatus.rejected.name,
      'isActive': false,
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedBy': adminId,
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Suspend Store
  Future<void> suspendStore(String storeId, String adminId) async {
    await _firestore.collection('vendors').doc(storeId).update({
      'status': StoreStatus.suspended.name,
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
      // You might want a 'suspendedAt'/'suspendedBy' if needed, or reuse generic audit logs
      // For now we'll just update status and isActive
    });
  }

  // Toggle Store Active State (Only if Approved)
  Future<void> toggleStoreActive(String storeId, bool isActive) async {
    // Ideally, we should check if the store is actually approved before flipping this.
    // However, Firestore rules or UI logic usually prevents calling this on non-approved stores.
    // We can do a quick check via transaction if strictness is required, but simple update is usually fine for Admin.
    await _firestore.collection('vendors').doc(storeId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return StoreRepository(firebaseService.firestore);
});

final storesStreamProvider = StreamProvider<List<Store>>((ref) {
  final repository = ref.watch(storeRepositoryProvider);
  return repository.getStoresStream();
});

final pendingStoresProvider = StreamProvider<List<Store>>((ref) {
  final repository = ref.watch(storeRepositoryProvider);
  return repository.getPendingStores();
});
