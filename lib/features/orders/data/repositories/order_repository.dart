import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:local_services_admin/features/finance/data/repositories/finance_repository.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  final FinanceRepository _financeRepository;

  OrderRepository(this._firestore, this._financeRepository);

  /// Streams all orders (Global Admin View)
  Stream<List<OrderModel>> getOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// Streams orders for a specific college
  Stream<List<OrderModel>> getCollegeOrdersStream(String collegeId) {
    return _firestore
        .collection('orders')
        .where('collegeId', isEqualTo: collegeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// Streams orders for a specific store
  Stream<List<OrderModel>> getStoreOrdersStream(String storeId) {
    return _firestore
        .collection('orders')
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // If order is delivered, trigger settlement
    if (status == OrderStatus.delivered) {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        final order = OrderModel.fromFirestore(doc);
        await _financeRepository.settleOrder(order);
      }
    }
  }

  /// Cancel order with reason
  Future<void> cancelOrder(String orderId, String reason) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.cancelled.name,
      'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final financeRepository = ref.watch(financeRepositoryProvider);
  return OrderRepository(firebaseService.firestore, financeRepository);
});

final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrdersStream();
});

final storeOrdersStreamProvider = StreamProvider.family<List<OrderModel>, String>((ref, storeId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getStoreOrdersStream(storeId);
});
