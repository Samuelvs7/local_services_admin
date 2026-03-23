import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/vendor_model.dart';

class VendorRepository {
  final FirebaseFirestore _firestore;

  VendorRepository(this._firestore);

  /// Stream all vendors (real-time updates).
  Stream<List<Vendor>> getVendorsStream() {
    return _firestore
        .collection('vendors')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vendor.fromFirestore(doc))
            .toList());
  }

  /// Stream only pending (unapproved) vendors.
  Stream<List<Vendor>> getPendingVendors() {
    return _firestore
        .collection('vendors')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vendor.fromFirestore(doc))
            .toList());
  }

  /// Approve a vendor.
  Future<void> approveVendor(String vendorId) async {
    await _firestore.collection('vendors').doc(vendorId).update({
      'isApproved': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reject (un-approve) a vendor.
  Future<void> rejectVendor(String vendorId) async {
    await _firestore.collection('vendors').doc(vendorId).update({
      'isApproved': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a vendor document from Firestore.
  Future<void> deleteVendor(String vendorId) async {
    await _firestore.collection('vendors').doc(vendorId).delete();
  }
}

// Providers
final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return VendorRepository(firebaseService.firestore);
});

final vendorsStreamProvider = StreamProvider<List<Vendor>>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return repository.getVendorsStream();
});

final pendingVendorsProvider = StreamProvider<List<Vendor>>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return repository.getPendingVendors();
});
