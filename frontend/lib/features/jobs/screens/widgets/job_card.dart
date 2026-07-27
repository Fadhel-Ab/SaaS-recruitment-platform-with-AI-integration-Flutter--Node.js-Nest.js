import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/features/jobs/models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(job.title, style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16),

                const SizedBox(width: 4),

                Text(job.location),
              ],
            ),

            const SizedBox(height: 8),

            Text(job.description, maxLines: 3, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,

              child: FilledButton(
                onPressed: onTap,
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
