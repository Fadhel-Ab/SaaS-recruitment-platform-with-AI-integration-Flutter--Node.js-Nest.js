import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/jobs/bloc/job_details_bloc.dart';
import 'package:frontend/features/jobs/bloc/job_details_state.dart';
import 'package:go_router/go_router.dart';

class JobDetailsScreen extends StatelessWidget {
  final String shareToken;

  const JobDetailsScreen({super.key, required this.shareToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),

      body: BlocBuilder<JobDetailsBloc, JobDetailsState>(
        builder: (context, state) {
          if (state.status == JobDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == JobDetailsStatus.failure) {
            return Center(child: Text(state.error ?? 'Failed to load job'));
          }

          final job = state.job;

          if (job == null) {
            return const Center(child: Text('Job not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 12),

                Text(job.location ?? 'Not specified'),

                const SizedBox(height: 20),

                Text(job.description),

                const SizedBox(height: 20),

                Text(job.requirements),

                const Spacer(),

                SizedBox(
                  width: double.infinity,

                  child: FilledButton(
                    onPressed: () {
                      context.push('/apply/${job.shareToken}');
                    },

                    child: const Text('Apply Now'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
