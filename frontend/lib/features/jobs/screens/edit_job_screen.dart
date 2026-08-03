import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/applications/widgets/form_label.dart';
import 'package:go_router/go_router.dart';

import '../data/jobs_repository.dart';
import '../models/job_model.dart';

class EditJobScreen extends StatefulWidget {
  final JobModel job;

  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();

  late final titleController = TextEditingController(text: widget.job.title);
  late final companyController = TextEditingController(
    text: widget.job.company ?? '',
  );
  late final descriptionController = TextEditingController(
    text: widget.job.description,
  );
  late final requirementsController = TextEditingController(
    text: widget.job.requirements,
  );
  late final locationController = TextEditingController(
    text: widget.job.location,
  );

  late String employmentType = widget.job.employmentType;
  late String skillLevel = widget.job.skillLevel ?? 'ENTRY';
  late String status = widget.job.status ?? 'ACTIVE';
  late final List<TextEditingController> _questionControllers =
      widget.job.interviewQuestions
          .map((q) => TextEditingController(text: q))
          .toList();
  bool _isSaving = false;

  final employmentTypes = const [
    'FULL_TIME',
    'PART_TIME',
    'CONTRACT',
    'INTERNSHIP',
    'REMOTE',
  ];

  final skillLevels = const ['ENTRY', 'INTERMEDIATE', 'SENIOR', 'EXPERT'];
  final statuses = const ['ACTIVE', 'EXPIRED', 'FULFILLED'];

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

  void _addQuestion() {
    setState(() => _questionControllers.add(TextEditingController()));
  }

  void _removeQuestion(int index) {
    setState(() => _questionControllers.removeAt(index).dispose());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final questions = _questionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      await context.read<JobsRepository>().updateJob(widget.job.id, {
        'title': titleController.text.trim(),
        'companyName': companyController.text.trim(),
        'description': descriptionController.text.trim(),
        'requirements': requirementsController.text.trim(),
        'location': locationController.text.trim(),
        'employmentType': employmentType,
        'skillLevel': skillLevel,
        'status': status,
        'interviewQuestions': questions,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job updated successfully'),
          backgroundColor: Color(0xFF047857),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update job: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Edit Job Posting'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel(label: 'Job Title', isRequired: false),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: titleController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a job title'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 500;
                          final companyField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormLabel(
                                label: 'Company Name',
                                isRequired: false,
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: companyController,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Company is required'
                                    : null,
                              ),
                            ],
                          );
                          final locationField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormLabel(
                                label: 'Location',
                                isRequired: false,
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: locationController,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Location is required'
                                    : null,
                              ),
                            ],
                          );
                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: companyField),
                                    const SizedBox(width: 16),
                                    Expanded(child: locationField),
                                  ],
                                )
                              : Column(
                                  children: [
                                    companyField,
                                    const SizedBox(height: 16),
                                    locationField,
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: 16),
                      const FormLabel(
                        label: 'Detailed Job Description',
                        isRequired: false,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 5,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Description cannot be blank'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const FormLabel(
                        label: 'Candidate Requirements',
                        isRequired: false,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: requirementsController,
                        maxLines: 3,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requirements specification is required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const FormLabel(
                        label: 'Employment Type',
                        isRequired: false,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: employmentTypes.map((type) {
                          final isSelected = employmentType == type;
                          return ChoiceChip(
                            label: Text(type.replaceAll('_', ' ')),
                            selected: isSelected,
                            selectedColor: const Color(0xFFEEF2FF),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF374151),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF4F46E5)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            onSelected: (_) =>
                                setState(() => employmentType = type),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const FormLabel(
                        label: 'Required Target Experience Level',
                        isRequired: false,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skillLevels.map((level) {
                          final isSelected = skillLevel == level;
                          return ChoiceChip(
                            label: Text(level),
                            selected: isSelected,
                            selectedColor: const Color(0xFFE0F2FE),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF0EA5E9)
                                  : const Color(0xFF374151),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF0EA5E9)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            onSelected: (_) =>
                                setState(() => skillLevel = level),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const FormLabel(label: 'Job Status', isRequired: false),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: statuses.map((s) {
                          final isSelected = status == s;
                          return ChoiceChip(
                            label: Text(s),
                            selected: isSelected,
                            selectedColor: const Color(0xFFE6F4EA),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF137333)
                                  : const Color(0xFF374151),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF137333)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            onSelected: (_) => setState(() => status = s),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const FormLabel(
                        label: 'AI Interview Questions',
                        isRequired: false,
                      ),
                      const SizedBox(height: 8),
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
                      TextButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Question'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
