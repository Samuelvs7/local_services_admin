import 'package:cloud_firestore/cloud_firestore.dart';

class PromoBanner {
  final String id;
  final String imageUrl;
  final String? redirectUrl;
  final String? targetId; // storeId or productId to open
  final String targetType; // 'store', 'product', 'external', 'none'
  final bool isActive;
  final int priority;
  final String? collegeId; // Specific college or null for global
  final DateTime createdAt;
  final String title;
  final String? subtitle;
  final String buttonText;

  PromoBanner({
    required this.id,
    required this.imageUrl,
    this.redirectUrl,
    this.targetId,
    required this.targetType,
    this.isActive = true,
    this.priority = 0,
    this.collegeId,
    required this.createdAt,
    this.title = '',
    this.subtitle,
    this.buttonText = 'Learn More',
  });

  factory PromoBanner.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromoBanner(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      redirectUrl: data['redirectUrl'],
      targetId: data['targetId'],
      targetType: data['targetType'] ?? 'none',
      isActive: data['isActive'] ?? true,
      priority: data['priority'] ?? 0,
      collegeId: data['collegeId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      buttonText: data['buttonText'] ?? 'Learn More',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'redirectUrl': redirectUrl,
      'targetId': targetId,
      'targetType': targetType,
      'isActive': isActive,
      'priority': priority,
      'collegeId': collegeId,
      'createdAt': createdAt,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
    };
  }

  PromoBanner copyWith({
    String? imageUrl,
    String? redirectUrl,
    String? targetId,
    String? targetType,
    bool? isActive,
    int? priority,
    String? collegeId,
    String? title,
    String? subtitle,
    String? buttonText,
  }) {
    return PromoBanner(
      id: id,
      imageUrl: imageUrl ?? this.imageUrl,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      collegeId: collegeId ?? this.collegeId,
      createdAt: createdAt,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      buttonText: buttonText ?? this.buttonText,
    );
  }
}
