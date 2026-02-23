enum AdminRole {
  super_admin,
  moderator,
  finance_admin,
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final bool isActive;
  final DateTime lastLogin;
  final String createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.lastLogin,
    required this.createdAt,
  });
}
