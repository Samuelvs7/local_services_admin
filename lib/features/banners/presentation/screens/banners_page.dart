import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_services_admin/features/banners/data/models/banner_model.dart';
import 'package:local_services_admin/features/banners/data/repositories/banner_repository.dart';
import 'package:local_services_admin/features/colleges/data/repositories/college_repository.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class BannersPage extends ConsumerStatefulWidget {
  const BannersPage({super.key});

  @override
  ConsumerState<BannersPage> createState() => _BannersPageState();
}

class _BannersPageState extends ConsumerState<BannersPage> {
  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(bannersStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promotional Banners',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage marketing assets and home screen carousels',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddBannerDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Banner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            bannersAsync.when(
              data: (banners) {
                if (banners.isEmpty) {
                  return _buildEmptyState();
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 16 / 10,
                  ),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    return _buildBannerCard(banners[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.add_photo_alternate_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No banners found', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Create your first banner to drive sales!'),
        ],
      ),
    );
  }

  Widget _buildBannerCard(PromoBanner banner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Switch(
                    value: banner.isActive,
                    onChanged: (v) {
                      ref.read(bannerRepositoryProvider).toggleActive(banner.id, v);
                      AppToastManager.instance.show(
                        title: 'Banner Updated',
                        description: 'Banner is now ${v ? 'active' : 'inactive'}.',
                      );
                    },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Priority: ${banner.priority}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          banner.targetType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteConfirm(banner.id),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.collegeId == null ? 'Global Placement' : 'Specific College',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    'Created: ${banner.createdAt.day}/${banner.createdAt.month}/${banner.createdAt.year}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(bannerRepositoryProvider).deleteBanner(id);
              AppToastManager.instance.show(
                title: 'Banner Deleted',
                description: 'The promotional asset has been removed.',
                variant: AppToastVariant.destructive,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddBannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddBannerDialog(),
    );
  }
}

class _AddBannerDialog extends ConsumerStatefulWidget {
  const _AddBannerDialog();

  @override
  ConsumerState<_AddBannerDialog> createState() => _AddBannerDialogState();
}

class _AddBannerDialogState extends ConsumerState<_AddBannerDialog> {
  final _urlController = TextEditingController();
  final _priorityController = TextEditingController(text: '0');
  String _targetType = 'none';
  String? _selectedCollegeId;

  @override
  Widget build(BuildContext context) {
    final collegesAsync = ref.watch(collegesStreamProvider);

    return AlertDialog(
      title: const Text('Add New Promo Banner'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://...',
                helperText: 'Paste a link to your hosting/cloud storage',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priorityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Display Priority',
                helperText: 'Higher numbers appear first',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _targetType,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('No Redirect')),
                DropdownMenuItem(value: 'store', child: Text('Link to Store')),
                DropdownMenuItem(value: 'external', child: Text('External Website')),
              ],
              onChanged: (v) => setState(() => _targetType = v!),
              decoration: const InputDecoration(labelText: 'Action Type'),
            ),
            const SizedBox(height: 16),
            collegesAsync.when(
              data: (colleges) => DropdownButtonFormField<String?>(
                initialValue: _selectedCollegeId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Global (All Colleges)')),
                  ...colleges.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _selectedCollegeId = v),
                decoration: const InputDecoration(labelText: 'Target College'),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error loading colleges: $e'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_urlController.text.isEmpty) return;
            
            final newBanner = PromoBanner(
              id: '', // Generated by Firestore
              imageUrl: _urlController.text,
              targetType: _targetType,
              priority: int.tryParse(_priorityController.text) ?? 0,
              collegeId: _selectedCollegeId,
              createdAt: DateTime.now(),
            );

            ref.read(bannerRepositoryProvider).addBanner(newBanner);
            AppToastManager.instance.show(
              title: 'Banner Created',
              description: 'Your new promo asset is now live.',
            );
            Navigator.pop(context);
          },
          child: const Text('Create Banner'),
        ),
      ],
    );
  }
}
