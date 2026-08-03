import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/availability/data/availability_repository.dart';
import 'package:frontend/features/availability/model/availability_slot.dart';

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

enum _LoadStatus { loading, success, failure }

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  _LoadStatus _status = _LoadStatus.loading;
  List<AvailabilitySlot> _slots = [];
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = _LoadStatus.loading);
    try {
      final slots = await context.read<AvailabilityRepository>().getMine();
      setState(() {
        _slots = slots;
        _status = _LoadStatus.success;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = _LoadStatus.failure;
      });
    }
  }

  Future<void> _addSlot() async {
    final result = await _showSlotDialog(context);
    if (result == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AvailabilityRepository>().create(
        dayOfWeek: result.dayOfWeek,
        startTime: result.startTime,
        endTime: result.endTime,
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add slot: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editSlot(AvailabilitySlot slot) async {
    final result = await _showSlotDialog(context, initial: slot);
    if (result == null || slot.id == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AvailabilityRepository>().update(
        slot.id!,
        dayOfWeek: result.dayOfWeek,
        startTime: result.startTime,
        endTime: result.endTime,
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update slot: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSlot(AvailabilitySlot slot) async {
    if (slot.id == null) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AvailabilityRepository>().delete(slot.id!);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete slot: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<AvailabilitySlot?> _showSlotDialog(
    BuildContext context, {
    AvailabilitySlot? initial,
  }) {
    return showDialog<AvailabilitySlot>(
      context: context,
      builder: (_) => _SlotFormDialog(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Interview Availability'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _addSlot,
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
      body: Builder(
        builder: (context) {
          if (_status == _LoadStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (_status == _LoadStatus.failure) {
            return Center(
              child: Text(
                _error ?? 'Failed to load availability',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          if (_slots.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 60,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No availability set yet',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add a slot to let the system schedule interviews.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _slots.length,
            itemBuilder: (context, index) {
              final slot = _slots[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: Text(
                      _dayLabels[(slot.dayOfWeek - 1) % 7],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  title: Text(
                    '${slot.startTime} - ${slot.endTime}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                        onPressed: _isSaving ? null : () => _editSlot(slot),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Color(0xFFC5221F),
                        ),
                        onPressed: _isSaving ? null : () => _deleteSlot(slot),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SlotFormDialog extends StatefulWidget {
  final AvailabilitySlot? initial;

  const _SlotFormDialog({this.initial});

  @override
  State<_SlotFormDialog> createState() => _SlotFormDialogState();
}

class _SlotFormDialogState extends State<_SlotFormDialog> {
  late int _day;
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _day = initial?.dayOfWeek ?? 1;
    _start = initial != null
        ? _parseTime(initial.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
    _end = initial != null
        ? _parseTime(initial.endTime)
        : const TimeOfDay(hour: 17, minute: 0);
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStart() async {
    final result = await showTimePicker(context: context, initialTime: _start);
    if (result != null) setState(() => _start = result);
  }

  Future<void> _pickEnd() async {
    final result = await showTimePicker(context: context, initialTime: _end);
    if (result != null) setState(() => _end = result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Availability' : 'Edit Availability'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: _day,
            isExpanded: true,
            items: [
              for (int i = 1; i <= 7; i++)
                DropdownMenuItem(value: i, child: Text(_dayLabels[i - 1])),
            ],
            onChanged: (v) => setState(() => _day = v!),
          ),
          ListTile(
            title: Text('Start: ${_start.format(context)}'),
            onTap: _pickStart,
          ),
          ListTile(
            title: Text('End: ${_end.format(context)}'),
            onTap: _pickEnd,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              AvailabilitySlot(
                id: widget.initial?.id,
                dayOfWeek: _day,
                startTime: _formatTime(_start),
                endTime: _formatTime(_end),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
