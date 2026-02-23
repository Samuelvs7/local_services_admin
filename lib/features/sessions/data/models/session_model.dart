import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  Session({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory Session.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Session(
      id: doc.id,
      name: data['name'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }

  Session copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
