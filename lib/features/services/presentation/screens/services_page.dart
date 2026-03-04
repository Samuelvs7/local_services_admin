import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_services_admin/features/services/data/models/service_config_model.dart';
import 'package:local_services_admin/features/services/data/repositories/service_repository.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  void _updateToggle(CollegeServiceConfig config, String type, bool value) {
    CollegeServiceConfig newConfig;
    if (type == 'food') {
      newConfig = config.copyWith(food: config.food.copyWith(enabled: value));
    } else if (type == 'bike') {
      newConfig = config.copyWith(bike: config.bike.copyWith(enabled: value));
    } else {
      newConfig = config.copyWith(parcel: config.parcel.copyWith(enabled: value));
    }
    ref.read(serviceRepositoryProvider).updateConfig(newConfig);
    AppToastManager.instance.show(
      title: 'Service Updated',
      description: '${type.toUpperCase()} is now ${value ? 'enabled' : 'disabled'} for ${config.collegeName}.',
    );
  }

  void _updateCommission(CollegeServiceConfig config, String type, String value) {
    final double? commission = double.tryParse(value);
    if (commission == null) return;

    CollegeServiceConfig newConfig;
    if (type == 'food') {
      newConfig = config.copyWith(food: config.food.copyWith(commission: commission));
    } else if (type == 'bike') {
      newConfig = config.copyWith(bike: config.bike.copyWith(commission: commission));
    } else {
      newConfig = config.copyWith(parcel: config.parcel.copyWith(commission: commission));
    }
    ref.read(serviceRepositoryProvider).updateConfig(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    final configsAsync = ref.watch(serviceConfigsStreamProvider);

    return configsAsync.when(
      data: (configs) {
        final activeFood = configs.where((c) => c.food.enabled).length;
        final activeBike = configs.where((c) => c.bike.enabled).length;
        final activeParcel = configs.where((c) => c.parcel.enabled).length;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Configuration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enable/disable services and set commission per college',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 32),

                // 1. Stats Row
                Row(
                  children: [
                    Expanded(child: _buildSummaryBox('Food Delivery', 'Active at $activeFood', Icons.restaurant_menu_rounded, Colors.green)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSummaryBox('Bike Rentals', 'Active at $activeBike', Icons.pedal_bike_rounded, Colors.blue)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSummaryBox('Parcel Delivery', 'Active at $activeParcel', Icons.inventory_2_rounded, Colors.purple)),
                  ],
                ),
                const SizedBox(height: 32),

                // 2. College Config List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: configs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) => _buildCollegeCard(configs[index]),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSummaryBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
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
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeCard(CollegeServiceConfig config) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(config.collegeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildServiceBox(config, 'food', 'Food Delivery', Icons.restaurant_rounded, config.food)),
              const SizedBox(width: 16),
              Expanded(child: _buildServiceBox(config, 'bike', 'Bike Hub', Icons.electric_moped_rounded, config.bike)),
              const SizedBox(width: 16),
              Expanded(child: _buildServiceBox(config, 'parcel', 'Parcel Ops', Icons.local_post_office_rounded, config.parcel)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBox(CollegeServiceConfig config, String type, String label, IconData icon, ServiceSetting settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: settings.enabled ? Theme.of(context).colorScheme.primary : Colors.grey),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: settings.enabled,
                  onChanged: (v) => _updateToggle(config, type, v),
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Commission %', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: TextField(
              enabled: settings.enabled,
              onChanged: (v) => _updateCommission(config, type, v),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                fillColor: settings.enabled ? Theme.of(context).inputDecorationTheme.fillColor : Theme.of(context).disabledColor.withValues(alpha: 0.05),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
              ),
              style: const TextStyle(fontSize: 13),
              controller: TextEditingController(text: settings.commission.toStringAsFixed(0))..selection = TextSelection.fromPosition(TextPosition(offset: settings.commission.toStringAsFixed(0).length)),
            ),
          ),
        ],
      ),
    );
  }
}
