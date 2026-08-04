import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/api/error_message.dart';
import 'package:frontend/features/availability/data/availability_repository.dart';
import 'package:frontend/features/availability/model/availability_slot.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';
import 'package:frontend/features/jobs/models/job_model.dart';

const _monthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _formatSlotDate(DateTime date) =>
    '${date.day} ${_monthLabels[date.month - 1]}';

String _describeSlot(AvailabilitySlot slot) {
  if (slot.recurrence == AvailabilityRecurrence.recurring) {
    final label = slot.dayOfWeek != null
        ? _dayLabels[(slot.dayOfWeek! - 1) % 7]
        : '?';
    return 'Every $label';
  }
  return slot.date != null ? _formatSlotDate(slot.date!) : 'No date';
}

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

enum _LoadStatus { loading, success, failure }

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  _LoadStatus _status = _LoadStatus.loading;
  List<AvailabilitySlot> _slots = [];
  List<JobModel> _allJobs = [];
  List<JobModel> _jobsWithAvailability = [];
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
      final results = await Future.wait([
        context.read<AvailabilityRepository>().getMine(),
        context.read<JobsRepository>().getMyJobs(),
      ]);
      final slots = results[0] as List<AvailabilitySlot>;
      final jobs = results[1] as List<JobModel>;
      setState(() {
        _slots = slots;
        _allJobs = jobs;
        _jobsWithAvailability = jobs
            .where((j) => j.jobAvailability.isNotEmpty)
            .toList();
        _status = _LoadStatus.success;
      });
    } catch (e) {
      setState(() {
        _error = friendlyErrorMessage(e);
        _status = _LoadStatus.failure;
      });
    }
  }

  Future<void> _addSlot() async {
    final result = await _showSlotDialog(context);
    if (result == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AvailabilityRepository>().create(result);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text('Failed to add slot: ${friendlyErrorMessage(e)}')),
        );
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
      await context.read<AvailabilityRepository>().update(slot.id!, result);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text('Failed to update slot: ${friendlyErrorMessage(e)}'),
          ),
        );
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
        ).showSnackBar(
          SnackBar(
            content: Text('Failed to delete slot: ${friendlyErrorMessage(e)}'),
          ),
        );
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
      builder: (_) => _SlotFormDialog(initial: initial, jobs: _allJobs),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(AvailabilitySlot slot, {bool editable = true}) {
    final isRecurring = slot.recurrence == AvailabilityRecurrence.recurring;
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
          child: Icon(
            isRecurring ? Icons.repeat : Icons.event_outlined,
            size: 18,
            color: const Color(0xFF4F46E5),
          ),
        ),
        title: Text(
          '${_describeSlot(slot)} · ${slot.startTime} - ${slot.endTime}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: editable
            ? Row(
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
              )
            : null,
      ),
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

          if (_slots.isEmpty && _jobsWithAvailability.isEmpty) {
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _buildSectionHeader(
                'General Availability',
                subtitle:
                    'Used as the default for new jobs when they don\'t have their own schedule. '
                    'Repeating slots recur every week; one-off slots apply to a single date.',
              ),
              if (_slots.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'No general slots set.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                )
              else
                ..._slots.map((slot) => _buildSlotCard(slot)),
              for (final job in _jobsWithAvailability) ...[
                _buildSectionHeader('Job: ${job.title}'),
                ...job.jobAvailability.map((slot) => _buildSlotCard(slot)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SlotFormDialog extends StatefulWidget {
  final AvailabilitySlot? initial;
  final List<JobModel> jobs;

  const _SlotFormDialog({this.initial, this.jobs = const []});

  @override
  State<_SlotFormDialog> createState() => _SlotFormDialogState();
}

class _SlotFormDialogState extends State<_SlotFormDialog> {
  late AvailabilityRecurrence _recurrence;
  late DateTime _date;
  late int _dayOfWeek;
  late TimeOfDay _start;
  late TimeOfDay _end;
  String? _jobId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final today = DateTime.now();
    _recurrence = initial?.recurrence ?? AvailabilityRecurrence.specific;
    _date = initial?.date ?? DateTime(today.year, today.month, today.day);
    _dayOfWeek = initial?.dayOfWeek ?? 1;
    _start = initial != null
        ? _parseTime(initial.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
    _end = initial != null
        ? _parseTime(initial.endTime)
        : const TimeOfDay(hour: 17, minute: 0);
    _jobId = initial?.jobId;
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

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 2),
    );
    if (result != null) setState(() => _date = result);
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
      title: Text(
        widget.initial == null ? 'Add Availability' : 'Edit Availability',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<AvailabilityRecurrence>(
            segments: const [
              ButtonSegment(
                value: AvailabilityRecurrence.recurring,
                label: Text('Weekly'),
                icon: Icon(Icons.repeat, size: 16),
              ),
              ButtonSegment(
                value: AvailabilityRecurrence.specific,
                label: Text('Date'),
                icon: Icon(Icons.event_outlined, size: 16),
              ),
            ],
            selected: {_recurrence},
            onSelectionChanged: (selection) =>
                setState(() => _recurrence = selection.first),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String?>(
            initialValue: _jobId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Applies to'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('General (all jobs)'),
              ),
              for (final job in widget.jobs)
                DropdownMenuItem<String?>(
                  value: job.id,
                  child: Text(job.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _jobId = v),
          ),
          const SizedBox(height: 14),
          if (_recurrence == AvailabilityRecurrence.recurring)
            DropdownButtonFormField<int>(
              initialValue: _dayOfWeek,
              decoration: const InputDecoration(labelText: 'Day of week'),
              items: [
                for (int i = 1; i <= 7; i++)
                  DropdownMenuItem(value: i, child: Text(_dayLabels[i - 1])),
              ],
              onChanged: (v) => setState(() => _dayOfWeek = v ?? _dayOfWeek),
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, size: 18),
              title: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              ),
              onTap: _pickDate,
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Start: ${_start.format(context)}'),
            onTap: _pickStart,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
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
            final slot = _recurrence == AvailabilityRecurrence.recurring
                ? AvailabilitySlot.recurring(
                    id: widget.initial?.id,
                    jobId: _jobId,
                    dayOfWeek: _dayOfWeek,
                    startTime: _formatTime(_start),
                    endTime: _formatTime(_end),
                  )
                : AvailabilitySlot.specific(
                    id: widget.initial?.id,
                    jobId: _jobId,
                    date: _date,
                    startTime: _formatTime(_start),
                    endTime: _formatTime(_end),
                  );
            Navigator.pop(context, slot);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
