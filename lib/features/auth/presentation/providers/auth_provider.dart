import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';

// State definitions
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final userCredential = await _authRepository.signIn(email, password);
      final user = userCredential.user;

      if (user == null) {
        state = AuthError('User not found');
        return;
      }

      // Check Role
      final userData = await _authRepository.getUserData(user.uid);
      if (userData == null) {
        state = AuthError('User record not found in database');
        await _authRepository.signOut();
        return;
      }

      final role = userData['role'];
      if (role != 'admin' && role != 'super_admin') {
        state = AuthError('Access Denied: You are not an Admin');
        await _authRepository.signOut();
        return;
      }

      state = AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      state = AuthError(e.message ?? 'Authentication failed');
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    state = AuthInitial();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
