import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/store_model.dart';
import '../../data/repositories/store_repository.dart';

// Service to expose the repository
// (Already defined in repository file, but re-exporting or using here is fine)
// We'll use the one from the repository file: storeRepositoryProvider

// Stream of Pending Stores
final pendingStoresProvider = StreamProvider<List<Store>>((ref) {
  final repository = ref.watch(storeRepositoryProvider);
  return repository.getPendingStores();
});

// Stream of Approved Stores
final approvedStoresProvider = StreamProvider<List<Store>>((ref) {
  final repository = ref.watch(storeRepositoryProvider);
  return repository.getApprovedStores();
});

// Controller for handling Store Actions (Approve, Reject, Suspend, Toggle)
// Using AsyncNotifier to handle loading/error states for these actions if UI needs it
class StoreActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // no-op initial state
  }

  Future<void> approveStore(String storeId, String adminId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(storeRepositoryProvider).approveStore(storeId, adminId));
  }

  Future<void> rejectStore(String storeId, String adminId, String reason) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
         ref.read(storeRepositoryProvider).rejectStore(storeId, adminId, reason));
  }

  Future<void> suspendStore(String storeId, String adminId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(storeRepositoryProvider).suspendStore(storeId, adminId));
  }

  Future<void> toggleStoreActive(String storeId, bool isActive) async {
    // Optimistic UI updates could be done here, but since we rely on streams, 
    // the UI will update automatically once Firestore updates.
    // We just handle the async call.
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(storeRepositoryProvider).toggleStoreActive(storeId, isActive));
  }
}

final storeActionControllerProvider =
    AsyncNotifierProvider<StoreActionController, void>(() {
  return StoreActionController();
});
