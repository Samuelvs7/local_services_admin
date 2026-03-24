import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/college_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollegeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<College>> getColleges() {
    return _firestore
        .collection('colleges')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => College.fromFirestore(doc))
          .where((c) => !c.isDeleted)
          .toList();
    });
  }

  Future<void> addCollege(Map<String, dynamic> data) async {
    await _firestore.collection('colleges').add({
      ...data,
      'isActive': true,
      'isDeleted': false,
      'bannerImage': data['bannerImage'] ?? 'https://via.placeholder.com/600x200',
      'createdAt': FieldValue.serverTimestamp(),
      'totalStudents': data['totalStudents'] ?? 0,
      'totalStores': 0,
      'totalOrders': 0,
      'revenue': 0.0,
    });
  }

  Future<void> updateCollege(String id, Map<String, dynamic> data) async {
    await _firestore.collection('colleges').doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleStatus(String id, bool newStatus) async {
    await _firestore.collection('colleges').doc(id).update({
      'isActive': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  Future<void> softDeleteCollege(String id) async {
     await _firestore.collection('colleges').doc(id).update({
       'isDeleted': true,
       'isActive': false,
       'updatedAt': FieldValue.serverTimestamp(),
     });
  }
}

final collegeServiceProvider = Provider<CollegeService>((ref) {
  return CollegeService();
});

final collegesStreamProvider = StreamProvider<List<College>>((ref) {
  final service = ref.watch(collegeServiceProvider);
  return service.getColleges();
});
