import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/banner_model.dart';

class BannerRepository {
  final FirebaseFirestore _firestore;

  BannerRepository(this._firestore);

  /// Streams all banners ordered by priority
  Stream<List<PromoBanner>> getBannersStream() {
    return _firestore
        .collection('banners')
        .orderBy('priority', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PromoBanner.fromFirestore(doc)).toList());
  }

  /// Add a new banner
  Future<void> addBanner(PromoBanner banner) async {
    await _firestore.collection('banners').add(banner.toMap());
  }

  /// Update an existing banner
  Future<void> updateBanner(PromoBanner banner) async {
    await _firestore.collection('banners').doc(banner.id).update(banner.toMap());
  }

  /// Delete a banner
  Future<void> deleteBanner(String id) async {
    await _firestore.collection('banners').doc(id).delete();
  }

  /// Toggle active status
  Future<void> toggleActive(String id, bool isActive) async {
    await _firestore.collection('banners').doc(id).update({'isActive': isActive});
  }
}

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return BannerRepository(firebaseService.firestore);
});

final bannersStreamProvider = StreamProvider<List<PromoBanner>>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return repository.getBannersStream();
});
