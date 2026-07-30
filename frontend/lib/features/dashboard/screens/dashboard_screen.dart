import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/dashboard/bloc/dashboard_event.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),

      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.failure) {
            return Center(child: Text(state.error ?? 'Something went wrong'));
          }

          final summary = state.summary;

          if (summary == null) {
            return const Center(child: Text('No dashboard data'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(LoadDashboard());
            },

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Recruitment Overview',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    crossAxisCount: MediaQuery.of(context).size.width > 700
                        ? 4
                        : 2,

                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,

                    children: [
                      _StatCard(
                        title: 'Active Jobs',
                        value: summary.activeJobs.toString(),
                        icon: Icons.work_outline,
                      ),

                      _StatCard(
                        title: 'Applications',
                        value: summary.totalApplications.toString(),
                        icon: Icons.people_outline,
                      ),

                      _StatCard(
                        title: 'AI Interviews',
                        value: summary.aiInterviews.toString(),
                        icon: Icons.phone_outlined,
                      ),

                      _StatCard(
                        title: 'AI Score',
                        value: '${summary.averageAIScore}%',
                        icon: Icons.smart_toy_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Application Pipeline',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  _PipelineTile(
                    title: 'Pending',
                    value: summary.pendingApplications,
                  ),

                  _PipelineTile(
                    title: 'Shortlisted',
                    value: summary.shortlisted,
                  ),

                  _PipelineTile(
                    title: 'Interview Completed',
                    value: summary.interviewsCompleted,
                  ),

                  _PipelineTile(title: 'Hired', value: summary.hired),

                  _PipelineTile(title: 'Rejected', value: summary.rejected),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Icon(icon, size: 30),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _PipelineTile extends StatelessWidget {
  final String title;
  final int value;

  const _PipelineTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),

        trailing: Text(
          value.toString(),

          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
