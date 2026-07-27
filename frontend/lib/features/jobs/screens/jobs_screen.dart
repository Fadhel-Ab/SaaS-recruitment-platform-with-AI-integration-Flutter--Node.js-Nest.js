import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/jobs/screens/job_details_screen.dart';
import 'package:frontend/features/jobs/screens/widgets/job_card.dart';

import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Jobs')),

      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          switch (state.status) {
            case JobsStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case JobsStatus.failure:
              return Center(child: Text(state.error ?? 'Error loading jobs'));

            case JobsStatus.loaded:
              if (state.jobs.isEmpty) {
                return const Center(child: Text('No jobs available'));
              }

              return ListView.builder(
                itemCount: state.jobs.length,

                itemBuilder: (context, index) {
                  final job = state.jobs[index];

                  return JobCard(
                    job: job,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(job: job),
                        ),
                      );
                    },
                  );
                },
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
