import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/admin_stats_model.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepository(this._firestore);

  /// Aggregates all live stats for the admin dashboard.
  Stream<AdminStats> getStatsStream() {
    return _firestore.collection('orders').snapshots().asyncMap((orderSnap) async {
      // 1. Get counts from other collections
      final userCountSnap = await _firestore.collection('users').count().get();
      final storesSnap = await _firestore.collection('stores').get();
      final collegesSnap = await _firestore.collection('colleges').get();
      final sessionsSnap = await _firestore.collection('sessions').count().get();

      // 2. Process Orders Data
      double totalRevenue = 0;
      double todayRevenue = 0;
      int todayOrders = 0;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      for (var doc in orderSnap.docs) {
        final data = doc.data();
        final amount = (data['totalAmount'] ?? 0).toDouble();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        if (data['status'] == 'delivered') {
          totalRevenue += amount;
          if (createdAt.isAfter(todayStart)) {
            todayRevenue += amount;
          }
        }

        if (createdAt.isAfter(todayStart)) {
          todayOrders++;
        }
      }

      // 3. Process Stores Data
      int pendingStores = storesSnap.docs.where((d) => d['status'] == 'pending').length;
      int activeStores = storesSnap.docs.where((d) => d['status'] == 'approved' && d['isActive'] == true).length;
      int rejectedStores = storesSnap.docs.where((d) => d['status'] == 'rejected').length;
      
      // 4. Process Colleges Data
      int totalColleges = collegesSnap.docs.where((d) => d['isDeleted'] == false).length;
      int activeColleges = collegesSnap.docs.where((d) => d['isActive'] == true && d['isDeleted'] == false).length;

      // 5. Process Financials from Payments collection
      final paymentsSnap = await _firestore.collection('payments').get();
      double totalCommission = 0;
      double pendingPayouts = 0;

      for (var doc in paymentsSnap.docs) {
        final data = doc.data();
        totalCommission += (data['platformCommission'] ?? 0).toDouble();
        if (data['status'] == 'pending') {
          pendingPayouts += (data['netPayout'] ?? 0).toDouble();
        }
      }

      return AdminStats(
        totalColleges: totalColleges,
        activeColleges: activeColleges,
        activeSessions: sessionsSnap.count ?? 0,
        totalStores: storesSnap.docs.length,
        activeStores: activeStores,
        pendingStoreApprovals: pendingStores,
        rejectedStores: rejectedStores,
        totalUsers: userCountSnap.count ?? 0,
        totalOrders: orderSnap.docs.length,
        totalRevenue: totalRevenue,
        totalCommission: totalCommission,
        pendingPayouts: pendingPayouts,
        todayOrders: todayOrders,
        todayRevenue: todayRevenue,
      );
    });
  }

  // Helper for old UI that might still use futures
  Future<AdminStats> getDashboardStats() async {
    return getStatsStream().first;
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return DashboardRepository(firebaseService.firestore);
});

final dashboardStatsProvider = StreamProvider<AdminStats>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getStatsStream();
});
