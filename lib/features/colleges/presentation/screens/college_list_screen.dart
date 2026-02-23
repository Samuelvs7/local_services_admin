import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/college_service.dart';
import '../../data/models/college_model.dart';
import '../../presentation/screens/college_detail_screen.dart';


class CollegeListScreen extends ConsumerStatefulWidget {
  const CollegeListScreen({super.key});

  @override
  ConsumerState<CollegeListScreen> createState() => _CollegeListScreenState();
}

class _CollegeListScreenState extends ConsumerState<CollegeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _formatCurrency(double amount) {
    return NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final collegesAsync = ref.watch(collegesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: collegesAsync.when(
        data: (colleges) {
          final filtered = colleges.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.name.toLowerCase().contains(query) || 
                   c.city.toLowerCase().contains(query);
          }).toList();

          final totalStudents = colleges.fold<int>(0, (sum, c) => sum + c.totalStudents);
          final totalRevenue = colleges.fold<double>(0, (sum, c) => sum + c.revenue);
          final activeCount = colleges.where((c) => c.isActive).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'College Management',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A2D3E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage partner institutions on the platform',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add College'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 2. Stats Grid
                LayoutBuilder(builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 72) / 4;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _buildStatBox('Total Colleges', '${colleges.length}', Icons.apartment_rounded, Colors.blue, cardWidth),
                      _buildStatBox('Active', '$activeCount', Icons.check_circle_outline_rounded, Colors.green, cardWidth),
                      _buildStatBox('Total Students', totalStudents.toString(), Icons.people_outline_rounded, Colors.orange, cardWidth),
                      _buildStatBox('Total Revenue', _formatCurrency(totalRevenue), Icons.payments_outlined, Colors.purple, cardWidth),
                    ],
                  );
                }),
                const SizedBox(height: 32),

                // 3. Data Table Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search & Filter Header
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 300,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => setState(() => _searchQuery = val),
                                decoration: const InputDecoration(
                                  hintText: 'Search colleges...',
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 18),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${filtered.length} results',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      
                      // Table
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.grey.withOpacity(0.05)),
                        child: DataTable(
                          columnSpacing: 24,
                          headingRowHeight: 50,
                          dataRowMaxHeight: 70,
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF9F9FA)),
                          columns: const [
                            DataColumn(label: _ColHeader('COLLEGE NAME')),
                            DataColumn(label: _ColHeader('STUDENTS')),
                            DataColumn(label: _ColHeader('STORES')),
                            DataColumn(label: _ColHeader('ORDERS')),
                            DataColumn(label: _ColHeader('REVENUE')),
                            DataColumn(label: _ColHeader('STATUS')),
                            DataColumn(label: _ColHeader('ACTIONS')),
                          ],
                          rows: filtered.map((c) => DataRow(
                            onSelectChanged: (val) {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => CollegeDetailScreen(college: c)));
                            },
                            cells: [
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E2D))),
                                  Text('${c.city}, ${c.state}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                ],
                              )),
                              DataCell(Text(c.totalStudents.toString(), style: const TextStyle(fontSize: 13))),
                              DataCell(Text(c.totalStores.toString(), style: const TextStyle(fontSize: 13))),
                              DataCell(Text(c.totalOrders.toString(), style: const TextStyle(fontSize: 13))),
                              DataCell(Text(_formatCurrency(c.revenue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green))),
                              DataCell(_StatusBadge(isActive: c.isActive)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    onPressed: () => _showAddEditDialog(context, college: c),
                                    color: Colors.blueGrey,
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    onPressed: () => _showDeleteConfirm(context, c),
                                    color: Colors.redAccent.withOpacity(0.7),
                                    tooltip: 'Deactivate',
                                  ),
                                ],
                              )),
                            ],
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width < 200 ? 200 : width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2D3E))),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {College? college}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditCollegeDialog(college: college),
    );
  }

  void _showDeleteConfirm(BuildContext context, College college) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate College'),
        content: Text('Are you sure you want to deactivate "${college.name}"? This will hide it from the platform.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(collegeServiceProvider).softDeleteCollege(college.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;
  const _ColHeader(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5));
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});
  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AddEditCollegeDialog extends ConsumerStatefulWidget {
  final College? college;
  const _AddEditCollegeDialog({this.college});

  @override
  ConsumerState<_AddEditCollegeDialog> createState() => __AddEditCollegeDialogState();
}

class __AddEditCollegeDialogState extends ConsumerState<_AddEditCollegeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _studentsController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.college?.name ?? '');
    _cityController = TextEditingController(text: widget.college?.city ?? '');
    _stateController = TextEditingController(text: widget.college?.state ?? '');
    _studentsController = TextEditingController(text: widget.college?.totalStudents.toString() ?? '0');
    _latController = TextEditingController(text: widget.college?.location.latitude.toString() ?? '12.8231');
    _lngController = TextEditingController(text: widget.college?.location.longitude.toString() ?? '80.0442');
    _isActive = widget.college?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.college == null ? 'Add New College' : 'Edit College'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('College Name', _nameController, 'e.g. SRM University'),
              _buildField('City', _cityController, 'e.g. Chennai'),
              _buildField('State', _stateController, 'e.g. Tamil Nadu'),
              _buildField('Total Students', _studentsController, '50000', isNumber: true),
              Row(
                children: [
                  Expanded(child: _buildField('Lat', _latController, '12.82', isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Lng', _lngController, '80.04', isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
                  Text(_isActive ? 'Active' : 'Inactive'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final data = {
                'name': _nameController.text,
                'city': _cityController.text,
                'state': _stateController.text,
                'totalStudents': int.parse(_studentsController.text),
                'location': GeoPoint(double.parse(_latController.text), double.parse(_lngController.text)),
                'isActive': _isActive,
              };

              if (widget.college == null) {
                await ref.read(collegeServiceProvider).addCollege(data);
              } else {
                await ref.read(collegeServiceProvider).updateCollege(widget.college!.id, data);
              }
              if (mounted) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              fillColor: const Color(0xFFF3F4F6),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
