import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/applications/widgets/form_label.dart';
import 'package:go_router/go_router.dart';

import '../bloc/create_job_bloc.dart';
import '../bloc/create_job_event.dart';
import '../bloc/create_job_state.dart';
import '../models/create_job_request.dart';

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
    super.dispose();
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateJobRequest(
      title: titleController.text.trim(),
      companyName: companyController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      requirements: requirementsController.text.trim(),
      employmentType: employmentType,
      skillLevel: skillLevel,
    );

    context.read<CreateJobBloc>().add(SubmitJobRequested(request));
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Position Specifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Fill out the template data fields below to feed our candidate matching AI engine.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 20),

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        const FormLabel(
                          label: 'Candidate Requirements',
                          isRequired: false,
                        ),
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
                        const FormLabel(
                          label: 'Employment Type',
                          isRequired: false,
                        ),
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
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
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
                              onSelected: (_) =>
                                  setState(() => employmentType = type),
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
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
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
                              onSelected: (_) =>
                                  setState(() => skillLevel = level),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 36),

                        // Submit Button Trigger Zone
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<CreateJobBloc, CreateJobState>(
                            builder: (context, state) {
                              final isSubmitting =
                                  state.status == CreateJobStatus.submitting;
                              return ElevatedButton(
                                onPressed: isSubmitting ? null : submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF6366F1,
                                  ), // Indigo
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
                              );
                            },
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
      ),
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
