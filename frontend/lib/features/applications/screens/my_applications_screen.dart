import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/applications/bloc/my_applications_bloc.dart';
import 'package:frontend/features/applications/bloc/my_applications_state.dart';
import 'package:frontend/features/applications/model/application_status.dart';
import 'package:frontend/features/applications/model/my_application_summary.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime date) {
  return '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(date)}, $hour:$minute $period';
}

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: BlocBuilder<MyApplicationsBloc, MyApplicationsState>(
        builder: (context, state) {
          if (state.status == MyApplicationsStatus.loading ||
              state.status == MyApplicationsStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (state.status == MyApplicationsStatus.failure) {
            return Center(
              child: Text(
                state.error ?? 'Failed to load your applications',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          if (state.applications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 60,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "You haven't applied to any jobs yet",
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.applications.length,
            itemBuilder: (context, index) {
              return _ApplicationCard(application: state.applications[index]);
            },
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final MyApplicationSummary application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final interview = application.interview;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.location != null
                            ? '${application.companyName} • ${application.location}'
                            : application.companyName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: application.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  'Applied ${_formatDate(application.appliedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                if (application.overallScore != null) ...[
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.analytics_outlined,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI Score: ${application.overallScore!.round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
            if (interview?.scheduledAt != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.event_available_outlined,
                      size: 18,
                      color: Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interview scheduled: ${_formatDateTime(interview!.scheduledAt!)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                          if (interview.meetingLink != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              interview.meetingLink!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4338CA),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
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
        statusLabel(status),
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
      case 'HIRED':
      case 'OFFERED':
        return (const Color(0xFFE6F4EA), const Color(0xFF137333));
      case 'REJECTED':
      case 'WITHDRAWN':
        return (const Color(0xFFFCE8E6), const Color(0xFFC5221F));
      case 'SHORTLISTED':
      case 'INTERVIEW_SCHEDULED':
      case 'INTERVIEW_COMPLETED':
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100));
      default:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
    }
  }
}
