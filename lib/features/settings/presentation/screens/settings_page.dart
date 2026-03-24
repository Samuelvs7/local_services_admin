import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';
import 'package:local_services_admin/features/settings/data/models/platform_settings_model.dart';
import 'package:local_services_admin/features/settings/data/repositories/settings_repository.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Platform Info
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _emailController = TextEditingController();

  // Feature Flags
  bool? _foodDelivery;
  bool? _bikeRental;
  bool? _parcelDelivery;
  bool? _pushNotifications;
  bool? _vendorDashboard;
  bool? _analytics;

  bool _isSaving = false;
  bool _initialized = false;

  void _handleSave(PlatformSettings currentSettings) async {
    setState(() => _isSaving = true);
    
    final updatedSettings = currentSettings.copyWith(
      platformName: _nameController.text,
      tagline: _taglineController.text,
      supportEmail: _emailController.text,
      foodDelivery: _foodDelivery,
      bikeRental: _bikeRental,
      parcelDelivery: _parcelDelivery,
      pushNotifications: _pushNotifications,
      vendorDashboard: _vendorDashboard,
      analytics: _analytics,
    );

    try {
      await ref.read(settingsRepositoryProvider).updateSettings(updatedSettings);
      if (mounted) {
        AppToastManager.instance.show(
          title: 'Settings Saved',
          description: 'Global platform configurations have been updated.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToastManager.instance.show(
          title: 'Error Saving Settings',
          description: e.toString(),
          variant: AppToastVariant.destructive,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(platformSettingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: settingsAsync.when(
        data: (settings) {
          if (!_initialized) {
            _nameController.text = settings.platformName;
            _taglineController.text = settings.tagline;
            _emailController.text = settings.supportEmail;
            _foodDelivery ??= settings.foodDelivery;
            _bikeRental ??= settings.bikeRental;
            _parcelDelivery ??= settings.parcelDelivery;
            _pushNotifications ??= settings.pushNotifications;
            _vendorDashboard ??= settings.vendorDashboard;
            _analytics ??= settings.analytics;
            _initialized = true;
          }

          return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Platform Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure global platform settings and feature flags',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),

            // 1. Platform Information
            _buildSection(
              title: 'Platform Information',
              icon: Icons.public_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Platform Name', _nameController, 'NexSus'),
                  _buildInputField('Tagline', _taglineController, 'Hyperlocal Campus Delivery'),
                  _buildInputField('Support Email', _emailController, 'support@example.in'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Feature Flags
            _buildSection(
              title: 'Feature Flags',
              icon: Icons.bolt_rounded,
              child: Column(
                children: [
                   _buildFeatureToggle(
                    'Food Delivery', 
                    'Enable food ordering from campus stores', 
                    _foodDelivery ?? settings.foodDelivery, 
                    (v) => setState(() => _foodDelivery = v),
                  ),
                   _buildFeatureToggle(
                    'Bike Rental', 
                    'Enable bike rental service', 
                    _bikeRental ?? settings.bikeRental, 
                    (v) => setState(() => _bikeRental = v),
                  ),
                   _buildFeatureToggle(
                    'Parcel Delivery', 
                    'Enable inter-campus parcel delivery', 
                    _parcelDelivery ?? settings.parcelDelivery, 
                    (v) => setState(() => _parcelDelivery = v),
                  ),
                   _buildFeatureToggle(
                    'Push Notifications', 
                    'Send push notifications to app users', 
                    _pushNotifications ?? settings.pushNotifications, 
                    (v) => setState(() => _pushNotifications = v),
                  ),
                   _buildFeatureToggle(
                    'Vendor Dashboard', 
                    'Allow vendors to access their dashboard', 
                    _vendorDashboard ?? settings.vendorDashboard, 
                    (v) => setState(() => _vendorDashboard = v),
                  ),
                   _buildFeatureToggle(
                    'Analytics Module', 
                    'Enable advanced analytics for admins', 
                    _analytics ?? settings.analytics, 
                    (v) => setState(() => _analytics = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _handleSave(settings),
                  icon: _isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                // Removed _showSaved logic as we use toasts now
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, s) => Center(child: Text('Error loading settings: $e')),
    ));
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFF6B00)),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 8),
          SizedBox(
            width: 500,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1)),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle(String title, String desc, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFF6B00),
          ),
        ],
      ),
    );
  }
}
