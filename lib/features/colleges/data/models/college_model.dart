import 'package:cloud_firestore/cloud_firestore.dart';

class College {
  final String id;
  final String name;
  final String shortName;
  final String city;
  final String state;
  final GeoPoint location;
  final bool isActive;
  final bool isDeleted;
  final String bannerImage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  // Analytics fields from React model
  final int totalStudents;
  final int totalStores;
  final int totalOrders;
  final double revenue;

  College({
    required this.id,
    required this.name,
    required this.shortName,
    required this.city,
    required this.state,
    required this.location,
    required this.isActive,
    required this.isDeleted,
    required this.bannerImage,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.totalStudents = 0,
    this.totalStores = 0,
    this.totalOrders = 0,
    this.revenue = 0.0,
  });

  factory College.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return College(
      id: doc.id,
      name: data['name'] ?? '',
      shortName: data['shortName'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      isActive: data['isActive'] ?? true,
      isDeleted: data['isDeleted'] ?? false,
      bannerImage: data['bannerImage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? '',
      totalStudents: data['totalStudents'] ?? 0,
      totalStores: data['totalStores'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      revenue: (data['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'shortName': shortName,
      'city': city,
      'state': state,
      'location': location,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'bannerImage': bannerImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'totalStudents': totalStudents,
      'totalStores': totalStores,
      'totalOrders': totalOrders,
      'revenue': revenue,
    };
  }
}
