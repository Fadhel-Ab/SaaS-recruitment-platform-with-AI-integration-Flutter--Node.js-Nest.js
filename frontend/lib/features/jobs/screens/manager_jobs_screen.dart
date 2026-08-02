import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/jobs/bloc/manager_jobs_event.dart';
import 'package:go_router/go_router.dart';

import '../bloc/manager_jobs_bloc.dart';
import '../bloc/manager_jobs_state.dart';

class ManagerJobsScreen extends StatelessWidget {
  const ManagerJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // navigate create job later
            },
          ),
        ],
      ),

      body: BlocBuilder<ManagerJobsBloc, ManagerJobsState>(
        builder: (context, state) {
          if (state.status == ManagerJobsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ManagerJobsStatus.failure) {
            return Center(child: Text(state.error ?? 'Something went wrong'));
          }

          if (state.jobs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.work_outline, size: 60),

                  SizedBox(height: 16),

                  Text('No jobs created yet'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ManagerJobsBloc>().add( LoadManagerJobs());
            },

            child: ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: state.jobs.length,

              itemBuilder: (context, index) {
                final job = state.jobs[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Expanded(
                              child: Text(
                                job.title,

                                style: const TextStyle(
                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            _StatusChip(status: job.status ?? 'ACTIVE'),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(job.company ?? 'No company'),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _InfoItem(
                              icon: Icons.school_outlined,

                              text: job.skillLevel ?? 'N/A',
                            ),

                            const SizedBox(width: 20),

                            _InfoItem(
                              icon: Icons.location_on_outlined,

                              text: job.location,
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text('Applications: ${job.applications ?? 0}'),

                            ElevatedButton(
                              onPressed: () {
                                context.push('/manager/jobs/${job.id}/applicants');
                              },

                              child: const Text('Candidates'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(status));
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;

  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon, size: 18), const SizedBox(width: 5), Text(text)],
    );
  }
}
