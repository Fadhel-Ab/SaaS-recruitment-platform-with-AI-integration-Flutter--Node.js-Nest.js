import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/jobs/bloc/manager_jobs_event.dart';
import 'package:frontend/features/jobs/models/job_model.dart';
import 'package:go_router/go_router.dart';

import '../bloc/manager_jobs_bloc.dart';
import '../bloc/manager_jobs_state.dart';

class ManagerJobsScreen extends StatelessWidget {
  const ManagerJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Post a new job',
            onPressed: () => context.push('/manager/create-job'),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: BlocBuilder<ManagerJobsBloc, ManagerJobsState>(
        builder: (context, state) {
          if (state.status == ManagerJobsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (state.status == ManagerJobsStatus.failure) {
            return Center(
              child: Text(
                state.error ?? 'Something went wrong',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          if (state.jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.work_outline,
                    size: 60,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No jobs created yet',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/manager/create-job'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Post your first job'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ManagerJobsBloc>().add(LoadManagerJobs());
            },

            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),

              itemCount: state.jobs.length,

              itemBuilder: (context, index) {
                final job = state.jobs[index];

                return _JobCard(
                  job: job,
                  onCandidatesTap: () =>
                      context.push('/manager/jobs/${job.id}/applicants'),
                  onEditTap: () async {
                    final result = await context.push<bool>(
                      '/manager/jobs/${job.id}/edit',
                      extra: job,
                    );
                    if (result == true && context.mounted) {
                      context.read<ManagerJobsBloc>().add(LoadManagerJobs());
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onCandidatesTap;
  final VoidCallback onEditTap;

  const _JobCard({
    required this.job,
    required this.onCandidatesTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                _StatusPill(status: job.status ?? 'ACTIVE'),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                  tooltip: 'Edit job',
                  onPressed: onEditTap,
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              job.company ?? 'No company',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _InfoItem(
                  icon: Icons.school_outlined,

                  text: job.skillLevel ?? 'N/A',
                ),

                const SizedBox(width: 20),

                _InfoItem(icon: Icons.location_on_outlined, text: job.location),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Applications: ${job.applications}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),

                ElevatedButton(
                  onPressed: onCandidatesTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Candidates'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;

  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors.$2,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(String status) {
    switch (status) {
      case 'ACTIVE':
        return (const Color(0xFFE6F4EA), const Color(0xFF137333));
      case 'FULFILLED':
        return (const Color(0xFFEEF2FF), const Color(0xFF4F46E5));
      case 'EXPIRED':
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
      default:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
    }
  }
}
