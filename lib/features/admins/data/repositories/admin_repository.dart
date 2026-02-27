import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/admin_user_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository(this._firestore);

  /// Streams all admin users
  Stream<List<AdminUser>> getAdminsStream() {
    return _firestore
        .collection('admins')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AdminUser.fromFirestore(doc)).toList());
  }

  /// Add a new admin
  Future<void> addAdmin(AdminUser admin) async {
    await _firestore.collection('admins').add(admin.toMap());
  }

  /// Update admin status
  Future<void> toggleAdminStatus(String adminId, bool isActive) async {
    await _firestore.collection('admins').doc(adminId).update({
      'isActive': isActive,
    });
  }

  /// Update admin role
  Future<void> updateAdminRole(String adminId, AdminRole role) async {
    await _firestore.collection('admins').doc(adminId).update({
      'role': role.name,
    });
  }

  /// Delete an admin
  Future<void> deleteAdmin(String adminId) async {
    await _firestore.collection('admins').doc(adminId).delete();
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AdminRepository(firebaseService.firestore);
});

final adminsStreamProvider = StreamProvider<List<AdminUser>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getAdminsStream();
});
