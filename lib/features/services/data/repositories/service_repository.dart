import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/service_config_model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepository(this._firestore);

  /// Streams service configurations for all colleges
  Stream<List<CollegeServiceConfig>> getServiceConfigsStream() {
    return _firestore
        .collection('service_configs')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CollegeServiceConfig.fromMap(doc.data())).toList());
  }

  /// Update a specific config for a college
  Future<void> updateConfig(CollegeServiceConfig config) async {
    await _firestore
        .collection('service_configs')
        .doc(config.collegeId)
        .set(config.toMap(), SetOptions(merge: true));
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return ServiceRepository(firebaseService.firestore);
});

final serviceConfigsStreamProvider = StreamProvider<List<CollegeServiceConfig>>((ref) {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getServiceConfigsStream();
});
