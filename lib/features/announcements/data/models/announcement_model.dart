import 'package:cloud_firestore/cloud_firestore.dart';

enum AnnouncementType { info, warning, success, critical }

class Announcement {
  final String id;
  final String title;
  final String message;
  final AnnouncementType type;
  final bool isActive;
  final String? collegeId; // null means global
  final DateTime createdAt;
  final DateTime? expiresAt;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.type = AnnouncementType.info,
    this.isActive = true,
    this.collegeId,
    required this.createdAt,
    this.expiresAt,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: AnnouncementType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'info'),
        orElse: () => AnnouncementType.info,
      ),
      isActive: data['isActive'] ?? true,
      collegeId: data['collegeId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'isActive': isActive,
      'collegeId': collegeId,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
    };
  }
}
