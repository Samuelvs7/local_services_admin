import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  paid,
  failed,
}

class PaymentLog {
  final String id;
  final String orderId;
  final String vendorName;
  final String storeId;
  final double amount;
  final double platformCommission;
  final double netPayout;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentLog({
    required this.id,
    required this.orderId,
    required this.vendorName,
    required this.storeId,
    required this.amount,
    required this.platformCommission,
    required this.netPayout,
    required this.status,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentLog(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      vendorName: data['vendorName'] ?? '',
      storeId: data['storeId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      platformCommission: (data['platformCommission'] ?? 0.0).toDouble(),
      netPayout: (data['netPayout'] ?? 0.0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'vendorName': vendorName,
      'storeId': storeId,
      'amount': amount,
      'platformCommission': platformCommission,
      'netPayout': netPayout,
      'status': status.name,
      'createdAt': createdAt,
      'paidAt': paidAt,
    };
  }

  PaymentLog copyWith({
    PaymentStatus? status,
    DateTime? paidAt,
  }) {
    return PaymentLog(
      id: id,
      orderId: orderId,
      vendorName: vendorName,
      storeId: storeId,
      amount: amount,
      platformCommission: platformCommission,
      netPayout: netPayout,
      status: status ?? this.status,
      createdAt: createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
