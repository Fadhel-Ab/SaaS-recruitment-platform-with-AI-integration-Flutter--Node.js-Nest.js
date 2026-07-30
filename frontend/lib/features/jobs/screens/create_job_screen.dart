import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void submit() {
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
      appBar: AppBar(title: const Text('Create Job')),

      body: BlocListener<CreateJobBloc, CreateJobState>(
        listener: (context, state) {
          if (state.status == CreateJobStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job created successfully')),
            );

            context.go('/manager/jobs');
          }

          if (state.status == CreateJobStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'Error creating job')),
            );
          }
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              TextField(
                controller: titleController,

                decoration: const InputDecoration(labelText: 'Job Title'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: companyController,

                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              TextField(
                controller: locationController,

                decoration: const InputDecoration(labelText: 'Location'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: descriptionController,

                maxLines: 5,

                decoration: const InputDecoration(labelText: 'Description'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: requirementsController,

                maxLines: 3,

                decoration: const InputDecoration(labelText: 'Requirements'),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: employmentType,

                decoration: const InputDecoration(labelText: 'Employment Type'),

                items: employmentTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),

                onChanged: (value) {
                  setState(() {
                    employmentType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: skillLevel,

                decoration: const InputDecoration(labelText: 'Skill Level'),

                items: skillLevels
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),

                onChanged: (value) {
                  setState(() {
                    skillLevel = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: BlocBuilder<CreateJobBloc, CreateJobState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.status == CreateJobStatus.submitting
                          ? null
                          : submit,

                      child: state.status == CreateJobStatus.submitting
                          ? const CircularProgressIndicator()
                          : const Text('Create Job'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
