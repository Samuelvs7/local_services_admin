import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a vendor from the `vendors` Firestore collection.
/// This model matches the vendor app's AppUser model structure.
class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // "vendor", "delivery", "both"
  final String? avatarUrl;
  final bool isApproved;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Vendor-specific fields
  final String? storeName;
  final String? storeAddress;
  final bool storeOpen;

  // Delivery-specific fields
  final String? vehicleType;
  final String? vehicleNumber;
  final bool isOnline;

  const Vendor({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'vendor',
    this.avatarUrl,
    this.isApproved = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.storeName,
    this.storeAddress,
    this.storeOpen = false,
    this.vehicleType,
    this.vehicleNumber,
    this.isOnline = false,
  });

  factory Vendor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vendor(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'vendor',
      avatarUrl: data['avatarUrl'] as String?,
      isApproved: data['isApproved'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      storeName: data['storeName'] as String?,
      storeAddress: data['storeAddress'] as String?,
      storeOpen: data['storeOpen'] as bool? ?? false,
      vehicleType: data['vehicleType'] as String?,
      vehicleNumber: data['vehicleNumber'] as String?,
      isOnline: data['isOnline'] as bool? ?? false,
    );
  }
}
