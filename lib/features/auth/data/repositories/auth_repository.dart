import 'package:firebase_auth/firebase_auth.dart';
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
    final doc = await _firebaseService.firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  User? get currentUser => _firebaseService.auth.currentUser;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AuthRepository(firebaseService);
});
