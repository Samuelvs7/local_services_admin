import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  /// Get stream of all users
  Stream<List<UserProfile>> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList());
  }

  /// Toggle User Block Status
  Future<void> toggleUserBlock(String uid, bool isBlocked) async {
    await _firestore.collection('users').doc(uid).update({
      'isBlocked': isBlocked,
    });
  }

  /// Change user role (e.g. to admin)
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
    });
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return UserRepository(firebaseService.firestore);
});

final usersStreamProvider = StreamProvider<List<UserProfile>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersStream();
});
