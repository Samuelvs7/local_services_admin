import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/admin_stats_model.dart';
import 'package:local_services_admin/features/colleges/data/models/college_model.dart';
import 'package:local_services_admin/features/stores/data/models/store_model.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepository(this._firestore);

  /// Aggregates all live stats for the admin dashboard.
  Stream<AdminStats> getStatsStream() {
    return _firestore.collection('orders').snapshots().asyncMap((orderSnap) async {
      // 1. Get counts from other collections
      final userCountSnap = await _firestore.collection('users').count().get();
      final storesSnap = await _firestore.collection('vendors').get();
      final collegesSnap = await _firestore.collection('colleges').get();
      final sessionsSnap = await _firestore.collection('sessions').count().get();

      // 2. Process Orders Data
      double totalRevenue = 0;
      double todayRevenue = 0;
      int todayOrders = 0;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      
      final List<double> last7DaysRevenue = List.filled(7, 0.0);
      final Map<String, int> ordersByService = {};

      for (var doc in orderSnap.docs) {
        final data = doc.data();
        final amount = (data['totalAmount'] ?? 0).toDouble();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        final rawServiceType = data['serviceType']?.toString() ?? 'General';
        final serviceType = rawServiceType[0].toUpperCase() + rawServiceType.substring(1).toLowerCase();
        
        ordersByService[serviceType] = (ordersByService[serviceType] ?? 0) + 1;
        
        if (data['status'] == 'delivered') {
          totalRevenue += amount;
          if (createdAt.isAfter(todayStart)) {
            todayRevenue += amount;
          }
          
          final orderDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
          final dateDifference = todayStart.difference(orderDate).inDays;
          if (dateDifference >= 0 && dateDifference < 7) {
            last7DaysRevenue[6 - dateDifference] += amount;
          }
        }

        if (createdAt.isAfter(todayStart)) {
          todayOrders++;
        }
      }

      // 3. Process Stores Data
      int pendingStores = 0;
      int activeStores = 0;
      int rejectedStores = 0;
      int validStoreCount = 0;
      
      for (var d in storesSnap.docs) {
        final store = Store.fromFirestore(d);
        if (store.isDeleted) continue;
        
        validStoreCount++;
        if (store.status == StoreStatus.pending) {
          pendingStores++;
        } else if (store.status == StoreStatus.approved && store.isActive) {
          activeStores++;
        } else if (store.status == StoreStatus.rejected) {
          rejectedStores++;
        }
      }
      
      // 4. Process Colleges Data
      int totalColleges = 0;
      int activeColleges = 0;
      final Map<String, double> collegeRevenues = {};
      
      for (var d in collegesSnap.docs) {
        final college = College.fromFirestore(d);
        if (!college.isDeleted) {
          totalColleges++;
          if (college.isActive) activeColleges++;
          collegeRevenues[college.shortName.isNotEmpty ? college.shortName : college.name] = college.revenue;
        }
      }
      
      final sortedColleges = collegeRevenues.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topCollegesRevenue = Map.fromEntries(sortedColleges.take(4));

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
        totalStores: validStoreCount,
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
        last7DaysRevenue: last7DaysRevenue,
        ordersByService: ordersByService,
        topCollegesRevenue: topCollegesRevenue,
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
