class StoreAuditLog {
  final String id;
  final String storeId;
  final String action;
  final String previousStatus;
  final String newStatus;
  final String performedBy;
  final String? reason;
  final DateTime timestamp;

  StoreAuditLog({
    required this.id,
    required this.storeId,
    required this.action,
    required this.previousStatus,
    required this.newStatus,
    required this.performedBy,
    this.reason,
    required this.timestamp,
  });
}
