import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),

      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state.status == JobsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == JobsStatus.failure) {
            return Center(child: Text(state.error ?? 'Something went wrong'));
          }

          if (state.jobs.isEmpty) {
            return const Center(child: Text('No jobs available'));
          }

          return ListView.builder(
            itemCount: state.jobs.length,

            itemBuilder: (context, index) {
              final job = state.jobs[index];

              return Card(
                child: ListTile(
                  title: Text(job.title),

                  subtitle: Text(job.location ?? 'Remote'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
