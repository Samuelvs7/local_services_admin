import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore;

  AnnouncementRepository(this._firestore);

  Stream<List<Announcement>> getAnnouncementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromFirestore(doc))
            .toList());
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _firestore.collection('announcements').add(announcement.toMap());
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _firestore
        .collection('announcements')
        .doc(announcement.id)
        .update(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _firestore
        .collection('announcements')
        .doc(id)
        .update({'isActive': isActive});
  }
}

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AnnouncementRepository(firebaseService.firestore);
});

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementsStream();
});
