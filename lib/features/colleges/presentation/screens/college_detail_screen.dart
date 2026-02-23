import 'package:flutter/material.dart';
import '../../data/models/college_model.dart';
import '../../../sessions/presentation/widgets/session_list_widget.dart';

class CollegeDetailScreen extends StatelessWidget {
  final College college;

  const CollegeDetailScreen({super.key, required this.college});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(college.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Sessions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            SessionListWidget(collegeId: college.id),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (college.bannerImage.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(college.bannerImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _detailRow('Short Name', college.shortName),
          _detailRow('City', college.city),
          _detailRow('State', college.state),
          _detailRow('Location', '${college.location.latitude}, ${college.location.longitude}'),
          _detailRow('Status', college.isActive ? 'Active' : 'Inactive'),
          _detailRow('ID', college.id),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
