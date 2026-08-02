import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/features/applications/bloc/job_applicants_bloc.dart';
import 'package:frontend/features/applications/bloc/job_applicants_state.dart';
import 'package:frontend/features/applications/model/applicant_summary.dart';
import 'package:frontend/features/applications/model/application_status.dart';

class JobApplicantsScreen extends StatelessWidget {
  final String jobId;

  const JobApplicantsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Candidates'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: BlocBuilder<JobApplicantsBloc, JobApplicantsState>(
        builder: (context, state) {
          if (state.status == JobApplicantsStatus.loading ||
              state.status == JobApplicantsStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (state.status == JobApplicantsStatus.failure) {
            return Center(
              child: Text(
                state.error ?? 'Failed to load candidates',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          if (state.applicants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 60,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.applicants.length,
            itemBuilder: (context, index) {
              final applicant = state.applicants[index];
              return _ApplicantCard(
                applicant: applicant,
                onTap: () =>
                    context.push('/manager/applications/${applicant.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicantSummary applicant;
  final VoidCallback onTap;

  const _ApplicantCard({required this.applicant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  applicant.candidateName.isNotEmpty
                      ? applicant.candidateName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.candidateName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      applicant.candidateEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (applicant.overallScore != null) ...[
                _ScorePill(score: applicant.overallScore!),
                const SizedBox(width: 12),
              ],
              _StatusPill(status: applicant.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final double score;

  const _ScorePill({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${score.round()}%',
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
