import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/notifications/data/models/notification_model.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Platform Maintenance',
        body: 'Scheduled maintenance this Sunday from 2 AM to 4 AM.',
        type: NotificationType.warning,
        sentBy: 'Admin (Samuel)',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        sentCount: 97500,
        targetName: 'All Users',
      ),
      NotificationModel(
        id: '2',
        title: 'New Feature: Flash Deals',
        body: 'Flash deals are now live! Check out the new section in the app.',
        type: NotificationType.promo,
        sentBy: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        sentCount: 97500,
        targetName: 'All Users',
      ),
      NotificationModel(
        id: '3',
        title: 'SRM Tech Fest 2026',
        body: 'Special discounts for students attending the tech fest.',
        type: NotificationType.info,
        sentBy: 'Admin (Samuel)',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        sentCount: 12000,
        targetName: 'SRM University',
      ),
    ];
  }

  void _addNotification(NotificationModel n) {
    setState(() {
      _notifications.insert(0, n);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
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
                      'Notifications',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Send broadcast notifications to users',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showComposeDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Notification'),
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
              final cardWidth = (constraints.maxWidth - 48) / 3;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildStatBox('Total Sent', '${_notifications.length}', Icons.notifications_active_rounded, Colors.blue, cardWidth),
                  _buildStatBox('Users Reached', '97.5K+', Icons.people_alt_rounded, Colors.green, cardWidth),
                  _buildStatBox('Colleges Targeted', '2', Icons.apartment_rounded, Colors.purple, cardWidth),
                ],
              );
            }),
            const SizedBox(height: 32),

            // 3. Notification List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _NotificationCard(notification: _notifications[index]),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width < 250 ? 250 : width,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ],
      ),
    );
  }

  void _showComposeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ComposeNotificationDialog(onSend: _addNotification),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    switch (notification.type) {
      case NotificationType.promo:
        typeColor = const Color(0xFFFF6B00);
        break;
      case NotificationType.alert:
        typeColor = Colors.red;
        break;
      case NotificationType.warning:
        typeColor = Colors.orange;
        break;
      case NotificationType.info:
        typeColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.notifications_rounded, color: typeColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    _TypeBadge(type: notification.type),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.body, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoItem('Target', notification.targetName ?? 'All Users'),
                    _InfoItem('Recipients', '${NumberFormat('#,###').format(notification.sentCount)} recipients'),
                    _InfoItem('By', notification.sentBy),
                    const Spacer(),
                    Text(DateFormat('dd/MM/yyyy').format(notification.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(text: value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final NotificationType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case NotificationType.info: color = Colors.blue; break;
      case NotificationType.warning: color = Colors.orange; break;
      case NotificationType.promo: color = const Color(0xFFFF6B00); break;
      case NotificationType.alert: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(type.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _ComposeNotificationDialog extends StatefulWidget {
  final Function(NotificationModel) onSend;
  const _ComposeNotificationDialog({required this.onSend});

  @override
  State<_ComposeNotificationDialog> createState() => __ComposeNotificationDialogState();
}

class __ComposeNotificationDialogState extends State<_ComposeNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _targetType = 'all';
  NotificationType _type = NotificationType.info;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Broadcast Notification'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Title', _titleController, 'e.g. Platform Update'),
              _buildField('Message', _bodyController, 'Notification body...', isMultiline: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TARGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _targetType,
                              isExpanded: true,
                              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                              onChanged: (v) => setState(() => _targetType = v!),
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('All Users')),
                                DropdownMenuItem(value: 'college', child: Text('By College')),
                                DropdownMenuItem(value: 'role', child: Text('By Role')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<NotificationType>(
                              value: _type,
                              isExpanded: true,
                              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                              onChanged: (v) => setState(() => _type = v!),
                              items: NotificationType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSend(NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                body: _bodyController.text,
                type: _type,
                sentBy: 'Super Admin',
                createdAt: DateTime.now(),
                sentCount: _targetType == 'all' ? 97500 : 12000,
                targetName: _targetType == 'all' ? 'All Users' : 'Target Selection',
              ));
              AppToastManager.instance.show(
                title: 'Notification Sent',
                description: 'Broadcast has been queued for delivery.',
              );
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Send'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: isMultiline ? 3 : 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
