import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? collegeId;
  final String? collegeName;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isBlocked;
  final String role;
  final int totalOrders;
  final double totalSpent;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.collegeId,
    this.collegeName,
    required this.createdAt,
    required this.lastActive,
    this.isBlocked = false,
    this.role = 'user',
    this.totalOrders = 0,
    this.totalSpent = 0.0,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? 'Guest',
      email: data['email'] ?? '',
      phone: data['phone'],
      collegeId: data['collegeId'],
      collegeName: data['collegeName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBlocked: data['isBlocked'] ?? false,
      role: data['role'] ?? 'user',
      totalOrders: data['totalOrders'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'collegeId': collegeId,
        'collegeName': collegeName,
        'createdAt': createdAt,
        'lastActive': lastActive,
        'isBlocked': isBlocked,
        'role': role,
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
      };
}
