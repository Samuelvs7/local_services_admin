class AdminStats {
  final int totalColleges;
  final int activeColleges;
  final int activeSessions;
  final int totalStores;
  final int activeStores;
  final int pendingStoreApprovals;
  final int rejectedStores;
  final int totalUsers;
  final int totalOrders;
  final double totalRevenue;
  final double totalCommission;
  final double pendingPayouts;
  final int todayOrders;
  final double todayRevenue;

  AdminStats({
    required this.totalColleges,
    required this.activeColleges,
    required this.activeSessions,
    required this.totalStores,
    required this.activeStores,
    required this.pendingStoreApprovals,
    required this.rejectedStores,
    required this.totalUsers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCommission,
    required this.pendingPayouts,
    required this.todayOrders,
    required this.todayRevenue,
  });

  factory AdminStats.empty() {
    return AdminStats(
      totalColleges: 0,
      activeColleges: 0,
      activeSessions: 0,
      totalStores: 0,
      activeStores: 0,
      pendingStoreApprovals: 0,
      rejectedStores: 0,
      totalUsers: 0,
      totalOrders: 0,
      totalRevenue: 0.0,
      totalCommission: 0.0,
      pendingPayouts: 0.0,
      todayOrders: 0,
      todayRevenue: 0.0,
    );
  }
}
