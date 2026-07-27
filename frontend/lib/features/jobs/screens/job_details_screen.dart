import 'package:flutter/material.dart';
import 'package:frontend/features/jobs/models/job_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title, style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 8),
                Text(job.location),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.work_outline),
                const SizedBox(width: 8),
                Text(job.employmentType),
              ],
            ),

            const SizedBox(height: 24),

            Text("Description", style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 8),

            Text(job.description),

            const SizedBox(height: 24),

            Text("Requirements", style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 8),

            Text(job.requirements),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // later
                },
                child: const Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
