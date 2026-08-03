import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/applications/widgets/form_label.dart';
import 'package:frontend/features/availability/model/availability_slot.dart';
import 'package:go_router/go_router.dart';

import '../bloc/create_job_bloc.dart';
import '../bloc/create_job_event.dart';
import '../bloc/create_job_state.dart';
import '../models/create_job_request.dart';

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class _EditableSlot {
  int dayOfWeek;
  TimeOfDay start;
  TimeOfDay end;

  _EditableSlot({
    required this.dayOfWeek,
    required this.start,
    required this.end,
  });

  factory _EditableSlot.fromAvailabilitySlot(AvailabilitySlot slot) {
    return _EditableSlot(
      dayOfWeek: slot.dayOfWeek,
      start: _parseTime(slot.startTime),
      end: _parseTime(slot.endTime),
    );
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  AvailabilitySlot toAvailabilitySlot() {
    return AvailabilitySlot(
      dayOfWeek: dayOfWeek,
      startTime: _formatTime(start),
      endTime: _formatTime(end),
    );
  }
}

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final locationController = TextEditingController();

  String employmentType = 'FULL_TIME';
  String skillLevel = 'ENTRY';

  // 0 = details, 1 = interview questions, 2 = interview availability
  int _step = 0;
  final List<TextEditingController> _questionControllers = [];
  final List<_EditableSlot> _availabilitySlots = [];

  final employmentTypes = const [
    'FULL_TIME',
    'PART_TIME',
    'CONTRACT',
    'INTERNSHIP',
    'REMOTE',
  ];

  final skillLevels = const ['ENTRY', 'INTERMEDIATE', 'SENIOR', 'EXPERT'];

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    locationController.dispose();
    for (final controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  CreateJobRequest _buildRequest() {
    return CreateJobRequest(
      title: titleController.text.trim(),
      companyName: companyController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      requirements: requirementsController.text.trim(),
      employmentType: employmentType,
      skillLevel: skillLevel,
    );
  }

  void _submitDetails() {
    if (!_formKey.currentState!.validate()) return;

    context.read<CreateJobBloc>().add(
      GenerateQuestionsRequested(_buildRequest()),
    );
  }

  void _goBackToDetails() {
    context.read<CreateJobBloc>().add(BackToJobDetailsRequested());
    setState(() {
      _step = 0;
      for (final controller in _questionControllers) {
        controller.dispose();
      }
      _questionControllers.clear();
    });
  }

  void _addQuestion() {
    setState(() => _questionControllers.add(TextEditingController()));
  }

  void _removeQuestion(int index) {
    setState(() => _questionControllers.removeAt(index).dispose());
  }

  void _approveQuestions() {
    final questions = _questionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one interview question')),
      );
      return;
    }

    context.read<CreateJobBloc>().add(QuestionsApproved(questions));
  }

  void _goBackToQuestions() {
    context.read<CreateJobBloc>().add(BackToQuestionsRequested());
    setState(() => _step = 1);
  }

  void _addAvailabilitySlot() {
    setState(
      () => _availabilitySlots.add(
        _EditableSlot(
          dayOfWeek: 1,
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 17, minute: 0),
        ),
      ),
    );
  }

  void _removeAvailabilitySlot(int index) {
    setState(() => _availabilitySlots.removeAt(index));
  }

  Future<void> _pickSlotStart(_EditableSlot slot) async {
    final result = await showTimePicker(context: context, initialTime: slot.start);
    if (result != null) setState(() => slot.start = result);
  }

  Future<void> _pickSlotEnd(_EditableSlot slot) async {
    final result = await showTimePicker(context: context, initialTime: slot.end);
    if (result != null) setState(() => slot.end = result);
  }

  void _publish() {
    if (_availabilitySlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one availability slot')),
      );
      return;
    }

    context.read<CreateJobBloc>().add(
      PublishJobRequested(
        _availabilitySlots.map((s) => s.toAvailabilitySlot()).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB), // AppColors.background
      appBar: AppBar(
        title: const Text('Post a Position'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: BlocListener<CreateJobBloc, CreateJobState>(
        listener: (context, state) {
          if (state.status == CreateJobStatus.questionsReady &&
              _questionControllers.isEmpty) {
            setState(() {
              _step = 1;
              _questionControllers.addAll(
                state.questions.map((q) => TextEditingController(text: q)),
              );
            });
          }

          if (state.status == CreateJobStatus.availabilityReady &&
              _availabilitySlots.isEmpty) {
            setState(() {
              _step = 2;
              if (state.defaultAvailability.isEmpty) {
                _availabilitySlots.add(
                  _EditableSlot(
                    dayOfWeek: 1,
                    start: const TimeOfDay(hour: 9, minute: 0),
                    end: const TimeOfDay(hour: 17, minute: 0),
                  ),
                );
              } else {
                _availabilitySlots.addAll(
                  state.defaultAvailability.map(
                    _EditableSlot.fromAvailabilitySlot,
                  ),
                );
              }
            });
          }

          if (state.status == CreateJobStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job configuration deployed successfully'),
                backgroundColor: Color(0xFF047857), // Success green
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/manager/jobs');
          }

          if (state.status == CreateJobStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Error deploying position'),
                backgroundColor: const Color(0xFFDC2626), // Error red
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 680,
              ), // Perfect for desktop & tablet profiles
              child: Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: switch (_step) {
                    0 => _buildDetailsStep(),
                    1 => _buildQuestionsStep(),
                    _ => _buildAvailabilityStep(),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepLabel(String step, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6366F1),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepLabel(
            'STEP 1 OF 3',
            'Position Specifications',
            'Fill out the template data fields below to feed our candidate matching AI engine.',
          ),

          // Title Field
          const FormLabel(label: 'Job Title', isRequired: false),
          const SizedBox(height: 6),
          TextFormField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'e.g. Senior Flutter Engineer',
              prefixIcon: Icon(Icons.badge_outlined, size: 20),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter a job title'
                : null,
          ),
          const SizedBox(height: 16),

          // Adaptive Company & Location Section Split
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCompanyField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildLocationField()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildCompanyField(),
                        const SizedBox(height: 16),
                        _buildLocationField(),
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),

          // Job Description Area Box
          const FormLabel(
            label: 'Detailed Job Description',
            isRequired: false,
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: descriptionController,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText:
                  'Detail core day-to-day operations and project team responsibilities...',
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Description cannot be blank'
                : null,
          ),
          const SizedBox(height: 16),

          // Core Requirements Area Box
          const FormLabel(label: 'Candidate Requirements', isRequired: false),
          const SizedBox(height: 6),
          TextFormField(
            controller: requirementsController,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText:
                  'List required frameworks, skills, certifications, or milestones...',
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Requirements specification is required'
                : null,
          ),
          const SizedBox(height: 20),

          // Employment Type Segment Strip Layout
          const FormLabel(label: 'Employment Type', isRequired: false),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: employmentTypes.map((type) {
              final bool isSelected = employmentType == type;
              return ChoiceChip(
                label: Text(type.replaceAll('_', ' ')),
                selected: isSelected,
                selectedColor: const Color(
                  0xFFEEF2FF,
                ), // AppColors.primaryLight
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF475569),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (_) => setState(() => employmentType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Target Skill Matrix Level Selector Segment Strip
          const FormLabel(
            label: 'Required Target Experience Level',
            isRequired: false,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skillLevels.map((level) {
              final bool isSelected = skillLevel == level;
              return ChoiceChip(
                label: Text(level),
                selected: isSelected,
                selectedColor: const Color(
                  0xFFE0F2FE,
                ), // AppColors.aiCyanLight
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFF475569),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (_) => setState(() => skillLevel = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),

          // Next Step Trigger Zone
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<CreateJobBloc, CreateJobState>(
              builder: (context, state) {
                final isGenerating =
                    state.status == CreateJobStatus.generatingQuestions;
                return ElevatedButton(
                  onPressed: isGenerating ? null : _submitDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1), // Indigo
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Next: Review AI Interview Questions',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepLabel(
          'STEP 2 OF 3',
          'Review Interview Questions',
          'These AI-generated questions will be asked during the candidate\'s phone interview. Edit, remove, or add your own before continuing.',
        ),
        ...List.generate(_questionControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${index + 1}.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _questionControllers[index],
                    maxLines: 2,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Interview question',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () => _removeQuestion(index),
                  tooltip: 'Remove question',
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Question'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
        ),
        const SizedBox(height: 32),
        BlocBuilder<CreateJobBloc, CreateJobState>(
          builder: (context, state) {
            final isLoading =
                state.status == CreateJobStatus.loadingAvailabilityDefaults;
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _goBackToDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _approveQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Next: Set Interview Availability',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvailabilityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepLabel(
          'STEP 3 OF 3',
          'Set Interview Availability',
          'Candidates who pass the AI screening will be automatically scheduled into one of these slots. Pre-filled from your last job — edit as needed.',
        ),
        ...List.generate(_availabilitySlots.length, (index) {
          final slot = _availabilitySlots[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: slot.dayOfWeek,
                        isExpanded: true,
                        items: [
                          for (int i = 1; i <= 7; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(_dayLabels[i - 1]),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => slot.dayOfWeek = v ?? slot.dayOfWeek),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: () => _pickSlotStart(slot),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Text(slot.start.format(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: () => _pickSlotEnd(slot),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Text(slot.end.format(context)),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () => _removeAvailabilitySlot(index),
                  tooltip: 'Remove slot',
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: _addAvailabilitySlot,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Slot'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
        ),
        const SizedBox(height: 32),
        BlocBuilder<CreateJobBloc, CreateJobState>(
          builder: (context, state) {
            final isSubmitting = state.status == CreateJobStatus.submitting;
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : _goBackToQuestions,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Deploy & Publish Job Listing',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompanyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel(label: 'Company Name', isRequired: false),
        const SizedBox(height: 6),
        TextFormField(
          controller: companyController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'e.g. TalentHQ Corp',
            prefixIcon: Icon(Icons.business_outlined, size: 20),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Company is required' : null,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel(label: 'Location', isRequired: false),
        const SizedBox(height: 6),
        TextFormField(
          controller: locationController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'e.g. Remote / London, UK',
            prefixIcon: Icon(Icons.location_on_outlined, size: 20),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Location is required' : null,
        ),
      ],
    );
  }
}
