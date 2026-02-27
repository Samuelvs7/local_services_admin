import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminRole {
  superAdmin,
  moderator,
  financeAdmin,
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final bool isActive;
  final DateTime lastLogin;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.lastLogin,
    required this.createdAt,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: AdminRole.values.firstWhere(
        (e) => e.name == (data['role'] ?? 'moderator'),
        orElse: () => AdminRole.moderator,
      ),
      isActive: data['isActive'] ?? true,
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'isActive': isActive,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
    };
  }
}
