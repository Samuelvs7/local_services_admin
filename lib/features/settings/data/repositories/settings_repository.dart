import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/platform_settings_model.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepository(this._firestore);

  /// Streams global platform settings
  Stream<PlatformSettings> getSettingsStream() {
    return _firestore
        .collection('settings')
        .doc('global')
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            // Default settings if not initialized in Firestore
            return PlatformSettings(
              platformName: 'NexSus',
              tagline: 'Hyperlocal Campus Delivery',
              supportEmail: 'support@nexsus.in',
              foodDelivery: true,
              bikeRental: true,
              parcelDelivery: true,
              pushNotifications: true,
              vendorDashboard: true,
              analytics: true,
            );
          }
          return PlatformSettings.fromMap(doc.data()!);
        });
  }

  /// Update platform settings
  Future<void> updateSettings(PlatformSettings settings) async {
    await _firestore
        .collection('settings')
        .doc('global')
        .set(settings.toMap(), SetOptions(merge: true));
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return SettingsRepository(firebaseService.firestore);
});

final platformSettingsProvider = StreamProvider<PlatformSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getSettingsStream();
});
