import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  out_for_delivery,
  delivered,
  cancelled,
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'price': price,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        name: map['name'] ?? '',
        quantity: (map['quantity'] ?? 0) as int,
        price: (map['price'] ?? 0.0).toDouble(),
      );
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String collegeId;
  final String collegeName;
  final String storeId;
  final String storeName;
  final String serviceType;
  final double totalAmount;
  final double deliveryFee;
  final double platformFee;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deliveryAddress;
  final List<OrderItem> items;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.collegeId,
    required this.collegeName,
    required this.storeId,
    required this.storeName,
    required this.serviceType,
    required this.totalAmount,
    required this.deliveryFee,
    required this.platformFee,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryAddress,
    required this.items,
    this.cancellationReason,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      collegeId: data['collegeId'] ?? '',
      collegeName: data['collegeName'] ?? 'Unknown College',
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? 'Unknown Store',
      serviceType: data['serviceType'] ?? 'general',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      platformFee: (data['platformFee'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((i) => OrderItem.fromMap(i))
          .toList(),
      cancellationReason: data['cancellationReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'storeId': storeId,
      'storeName': storeName,
      'serviceType': serviceType,
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'platformFee': platformFee,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'deliveryAddress': deliveryAddress,
      'items': items.map((i) => i.toMap()).toList(),
      'cancellationReason': cancellationReason,
    };
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? cancellationReason,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      userName: userName,
      collegeId: collegeId,
      collegeName: collegeName,
      storeId: storeId,
      storeName: storeName,
      serviceType: serviceType,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      platformFee: platformFee,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryAddress: deliveryAddress,
      items: items,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
