import 'package:flutter_riverpod/flutter_riverpod.dart';
export '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/admin_stats_model.dart';

// We export the repository provider so the UI can use it
// dashboardStatsProvider is already defined in the repository file as a StreamProvider

final legacyDashboardStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardStats();
});
