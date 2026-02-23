import 'package:cloud_firestore/cloud_firestore.dart';

enum StoreStatus {
  pending,
  approved,
  rejected,
  suspended,
}

class Store {
  final String id;
  final String name; // storeName
  final String ownerName;
  final String email;
  final String phone;
  final String collegeId;
  final String collegeName;
  final String ownerId;
  final String serviceType;
  final StoreStatus status;
  final bool isActive;
  final bool isDeleted;
  final String address;
  final List<String> documents;
  final double? rating;
  
  // Audit fields
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  Store({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.collegeId,
    required this.collegeName,
    required this.ownerId,
    required this.serviceType,
    this.status = StoreStatus.pending,
    this.isActive = false,
    this.isDeleted = false,
    required this.address,
    this.documents = const [],
    this.rating,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  Store copyWith({
    String? name,
    String? ownerName,
    String? email,
    String? phone,
    String? collegeId,
    String? collegeName,
    String? ownerId,
    String? serviceType,
    StoreStatus? status,
    bool? isActive,
    bool? isDeleted,
    String? address,
    List<String>? documents,
    double? rating,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return Store(
      id: id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      collegeId: collegeId ?? this.collegeId,
      collegeName: collegeName ?? this.collegeName,
      ownerId: ownerId ?? this.ownerId,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      address: address ?? this.address,
      documents: documents ?? this.documents,
      rating: rating ?? this.rating,
      createdAt: createdAt,
      createdBy: createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory Store.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Store(
      id: doc.id,
      name: data['storeName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      collegeId: data['collegeId'] ?? '',
      collegeName: data['collegeName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      status: StoreStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => StoreStatus.pending,
      ),
      isActive: data['isActive'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      address: data['address'] ?? '',
      documents: List<String>.from(data['documents'] ?? []),
      rating: (data['rating'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'],
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeName': name,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'ownerId': ownerId,
      'serviceType': serviceType,
      'status': status.name,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'address': address,
      'documents': documents,
      'rating': rating,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }
}
