import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../data/models/session_model.dart';
import '../providers/session_provider.dart';

class AddEditSessionDialog extends ConsumerStatefulWidget {
  final String collegeId;
  final Session? session; // If null, adding new session

  const AddEditSessionDialog({super.key, required this.collegeId, this.session});

  @override
  ConsumerState<AddEditSessionDialog> createState() => _AddEditSessionDialogState();
}

class _AddEditSessionDialogState extends ConsumerState<AddEditSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session?.name ?? '');
    _startDate = widget.session?.startDate ?? DateTime.now();
    _endDate = widget.session?.endDate ?? DateTime.now().add(const Duration(days: 365));
    _isActive = widget.session?.isActive ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-adjust end date if start is after end
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 365));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final createdBy = currentUser?.email ?? currentUser?.uid ?? 'unknown_admin';

    final newSession = Session(
      id: widget.session?.id ?? '', 
      name: _nameController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
      isDeleted: false,
      createdAt: widget.session?.createdAt ?? DateTime.now(),
      createdBy: widget.session?.createdBy ?? createdBy,
    );

    try {
      if (widget.session == null) {
        await ref.read(sessionActionProvider.notifier).addSession(widget.collegeId, newSession);
      } else {
        await ref.read(sessionActionProvider.notifier).updateSession(widget.collegeId, newSession);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final isLoading = ref.watch(sessionActionProvider).isLoading;

    return AlertDialog(
      title: Text(widget.session == null ? 'Add Session' : 'Edit Session'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Session Name (e.g. 2024-2025)'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Date'),
                        child: Text(dateFormat.format(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End Date'),
                        child: Text(dateFormat.format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active?'),
                subtitle: const Text('Activating this will deactivate others.'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.session == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
