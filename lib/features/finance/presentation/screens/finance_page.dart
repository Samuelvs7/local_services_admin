import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/finance/data/models/payment_log_model.dart';
import 'package:local_services_admin/features/finance/data/repositories/finance_repository.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  String _formatCurrency(double amount) {
    return NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0).format(amount);
  }

  void _markPaid(String id) {
    ref.read(financeRepositoryProvider).markAsPaid(id);
    AppToastManager.instance.show(
      title: 'Payout Successful',
      description: 'Vendor payment has been marked as completed.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(paymentLogsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: logsAsync.when(
        data: (logs) {
          final totalGMV = logs.fold<double>(0, (sum, l) => sum + l.amount);
          final totalCommission = logs.fold<double>(0, (sum, l) => sum + l.platformCommission);
          final pendingPayout = logs.where((l) => l.status == PaymentStatus.pending).fold<double>(0, (sum, l) => sum + l.netPayout);
          final paidOut = logs.where((l) => l.status == PaymentStatus.paid).fold<double>(0, (sum, l) => sum + l.netPayout);

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
                        Text(
                          'Financial Management',
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Theme.of(context).textTheme.bodyLarge?.color
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track earnings, commissions, and vendor payouts',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                         AppToastManager.instance.show(
                          title: 'Export Started',
                          description: 'Your CSV report is being generated.',
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export CSV'),
                      style: OutlinedButton.styleFrom(
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
                      _buildStatBox('Total GMV', _formatCurrency(totalGMV), Icons.payments_rounded, Colors.blue, cardWidth),
                      _buildStatBox('Commission', _formatCurrency(totalCommission), Icons.trending_up_rounded, Colors.green, cardWidth),
                      _buildStatBox('Pending', _formatCurrency(pendingPayout), Icons.history_rounded, Colors.orange, cardWidth),
                      _buildStatBox('Paid Out', _formatCurrency(paidOut), Icons.check_circle_outline_rounded, Colors.purple, cardWidth),
                    ],
                  );
                }),
                const SizedBox(height: 32),

                // 3. Table Card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${logs.length} transactions', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                      DataTable(
                        columnSpacing: 24,
                        headingRowHeight: 50,
                        dataRowMaxHeight: 65,
                        headingRowColor: WidgetStateProperty.all(Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                        columns: const [
                          DataColumn(label: _ColHeader('ORDER ID')),
                          DataColumn(label: _ColHeader('VENDOR')),
                          DataColumn(label: _ColHeader('AMOUNT')),
                          DataColumn(label: _ColHeader('COMMISSION')),
                          DataColumn(label: _ColHeader('NET PAYOUT')),
                          DataColumn(label: _ColHeader('STATUS')),
                          DataColumn(label: _ColHeader('DATE')),
                          DataColumn(label: _ColHeader('ACTION')),
                        ],
                        rows: logs.map((l) => DataRow(
                          cells: [
                            DataCell(Text(l.orderId, style: TextStyle(fontFamily: 'monospace', color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                            DataCell(Text(l.vendorName, style: const TextStyle(fontSize: 13))),
                            DataCell(Text(_formatCurrency(l.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                            DataCell(Text(_formatCurrency(l.platformCommission), style: const TextStyle(fontSize: 13, color: Colors.orange))),
                            DataCell(Text(_formatCurrency(l.netPayout), style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold))),
                            DataCell(_StatusBadge(status: l.status)),
                            DataCell(Text(DateFormat('dd/MM/yyyy').format(l.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                            DataCell(
                              l.status == PaymentStatus.pending 
                              ? TextButton(
                                  onPressed: () => _markPaid(l.id),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                                    foregroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('Mark Paid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                )
                              : Text(l.paidAt != null ? DateFormat('dd/MM/yyyy').format(l.paidAt!) : '—', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            ),
                          ],
                        )).toList(),
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
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width < 220 ? 220 : width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
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
  final PaymentStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case PaymentStatus.paid:
        color = Colors.green;
        break;
      case PaymentStatus.pending:
        color = Colors.orange;
        break;
      case PaymentStatus.failed:
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
