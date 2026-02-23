enum NotificationType {
  info,
  promo,
  warning,
  alert,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String sentBy;
  final DateTime createdAt;
  final int sentCount;
  final String? targetName;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.sentBy,
    required this.createdAt,
    required this.sentCount,
    this.targetName,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? sentBy,
    DateTime? createdAt,
    int? sentCount,
    String? targetName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      sentBy: sentBy ?? this.sentBy,
      createdAt: createdAt ?? this.createdAt,
      sentCount: sentCount ?? this.sentCount,
      targetName: targetName ?? this.targetName,
    );
  }
}
