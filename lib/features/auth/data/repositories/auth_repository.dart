import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';

class AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepository(this._firebaseService);

  Future<UserCredential> signIn(String email, String password) async {
    return _firebaseService.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseService.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      print('DEBUG: Attempting to read admins/$uid from SERVER');
      final doc = await _firebaseService.firestore
          .collection('admins')
          .doc(uid)
          .get(const GetOptions(source: Source.server));
      print('DEBUG: doc.exists = ${doc.exists}');
      print('DEBUG: doc.data() = ${doc.data()}');
      print('DEBUG: doc.id = ${doc.id}');
      if (!doc.exists) {
        print('DEBUG: Document does NOT exist in Firestore!');
        return null;
      }
      return doc.data();
    } catch (e) {
      print('DEBUG: Error reading admin document: $e');
      rethrow;
    }
  }

  User? get currentUser => _firebaseService.auth.currentUser;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AuthRepository(firebaseService);
});
