import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/models/session_model.dart';

// Repository Provider
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return SessionRepository(firebaseService.firestore);
});

// Stream Provider for Sessions
final sessionsStreamProvider = StreamProvider.family<List<Session>, String>((ref, collegeId) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.getSessionsStream(collegeId);
});

// Controller for Session Actions (Add, Update, Delete)
class SessionController extends StateNotifier<AsyncValue<void>> {
  final SessionRepository _repository;

  SessionController(this._repository) : super(const AsyncValue.data(null));

  Future<void> addSession(String collegeId, Session session) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.addSession(collegeId, session));
  }

  Future<void> updateSession(String collegeId, Session session) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateSession(collegeId, session));
  }

  Future<void> deleteSession(String collegeId, String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteSession(collegeId, sessionId));
  }

  Future<void> toggleStatus(String collegeId, Session session, bool isActive) async {
     // If we are turning it ON, we might need to deactivate others (handled by repo update/add logic usually, 
     // but here we are just toggling. The repo updateSession handles the logic if isActive is true.
     // So we just create a copy with new status and call update.
     final updated = session.copyWith(isActive: isActive);
     await updateSession(collegeId, updated);
  }
}

final sessionActionProvider = StateNotifierProvider<SessionController, AsyncValue<void>>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return SessionController(repository);
});
