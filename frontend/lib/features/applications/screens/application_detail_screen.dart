import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/applications/bloc/application_detail_bloc.dart';
import 'package:frontend/features/applications/bloc/application_detail_event.dart';
import 'package:frontend/features/applications/bloc/application_detail_state.dart';
import 'package:frontend/features/applications/model/application_detail.dart';
import 'package:frontend/features/applications/model/application_status.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final String applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Candidate Review'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: BlocConsumer<ApplicationDetailBloc, ApplicationDetailState>(
        listenWhen: (previous, current) =>
            current.updateError != null &&
            current.updateError != previous.updateError,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.updateError!)),
          );
        },
        builder: (context, state) {
          if (state.status == ApplicationDetailStatus.loading ||
              state.status == ApplicationDetailStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (state.status == ApplicationDetailStatus.failure ||
              state.application == null) {
            return Center(
              child: Text(
                state.error ?? 'Failed to load candidate',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          final application = state.application!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CandidateHeaderCard(application: application),
                    const SizedBox(height: 16),
                    if (application.aiScore != null) ...[
                      _AiScoreCard(aiScore: application.aiScore!),
                      const SizedBox(height: 16),
                    ],
                    _TranscriptCard(application: application),
                    const SizedBox(height: 16),
                    _StatusActionsCard(
                      application: application,
                      isUpdating: state.isUpdatingStatus,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _CandidateHeaderCard extends StatelessWidget {
  final ApplicationDetail application;

  const _CandidateHeaderCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFEEF2FF),
              child: Text(
                application.candidateName.isNotEmpty
                    ? application.candidateName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.candidateName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applied for ${application.jobTitle}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        icon: Icons.email_outlined,
                        text: application.candidateEmail,
                      ),
                      _InfoChip(
                        icon: Icons.phone_outlined,
                        text: application.candidatePhone,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel(application.status),
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _AiScoreCard extends StatelessWidget {
  final AiScoreDetail aiScore;

  const _AiScoreCard({required this.aiScore});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'AI Evaluation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScoreMetric(label: 'CV Score', value: aiScore.cvScore),
              if (aiScore.interviewScore != null)
                _ScoreMetric(
                  label: 'Interview Score',
                  value: aiScore.interviewScore!,
                ),
              _ScoreMetric(
                label: 'Overall Score',
                value: aiScore.overallScore,
                highlight: true,
              ),
            ],
          ),
          if (aiScore.summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              aiScore.summary,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
            ),
          ],
          if (aiScore.recommendation.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Recommendation',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              aiScore.recommendation,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
            ),
          ],
          if (aiScore.strengths.isNotEmpty) ...[
            const SizedBox(height: 16),
            _TagGroup(
              label: 'Strengths',
              tags: aiScore.strengths,
              color: const Color(0xFF137333),
              background: const Color(0xFFE6F4EA),
            ),
          ],
          if (aiScore.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TagGroup(
              label: 'Weaknesses',
              tags: aiScore.weaknesses,
              color: const Color(0xFFC5221F),
              background: const Color(0xFFFCE8E6),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreMetric extends StatelessWidget {
  final String label;
  final double value;
  final bool highlight;

  const _ScoreMetric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '${value.round()}%',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: highlight ? const Color(0xFF4F46E5) : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _TagGroup extends StatelessWidget {
  final String label;
  final List<String> tags;
  final Color color;
  final Color background;

  const _TagGroup({
    required this.label,
    required this.tags,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  final ApplicationDetail application;

  const _TranscriptCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final interview = application.aiInterview;

    if (interview == null) {
      return _SectionCard(
        title: 'AI Interview Conversation',
        child: const Text(
          'No AI interview has taken place for this application yet.',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      );
    }

    final qaPairs = interview.qaPairs;

    return _SectionCard(
      title: 'AI Interview Conversation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (interview.summary != null && interview.summary!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                interview.summary!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (qaPairs.isNotEmpty)
            ...qaPairs.map((pair) => _QaBubblePair(pair: pair))
          else if (interview.transcript != null &&
              interview.transcript!.trim().isNotEmpty)
            Text(
              interview.transcript!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.6),
            )
          else
            const Text(
              'The interview call has not produced a transcript yet.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
        ],
      ),
    );
  }
}

class _QaBubblePair extends StatelessWidget {
  final QaPair pair;

  const _QaBubblePair({required this.pair});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pair.question.isNotEmpty)
            _Bubble(
              label: 'Interviewer',
              text: pair.question,
              background: const Color(0xFFEEF2FF),
              labelColor: const Color(0xFF4F46E5),
              alignStart: true,
            ),
          if (pair.question.isNotEmpty && pair.answer.isNotEmpty)
            const SizedBox(height: 8),
          if (pair.answer.isNotEmpty)
            _Bubble(
              label: 'Candidate',
              text: pair.answer,
              background: const Color(0xFFF3F4F6),
              labelColor: const Color(0xFF111827),
              alignStart: false,
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String label;
  final String text;
  final Color background;
  final Color labelColor;
  final bool alignStart;

  const _Bubble({
    required this.label,
    required this.text,
    required this.background,
    required this.labelColor,
    required this.alignStart,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(fontSize: 13, color: Color(0xFF111827), height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusActionsCard extends StatelessWidget {
  final ApplicationDetail application;
  final bool isUpdating;

  const _StatusActionsCard({required this.application, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    final nextStatuses = allowedStatusTransitions[application.status] ?? const [];

    if (nextStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: 'Update Status',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: nextStatuses.map((status) {
          final isDestructive = status == 'REJECTED' || status == 'WITHDRAWN';
          return ElevatedButton(
            onPressed: isUpdating
                ? null
                : () => context.read<ApplicationDetailBloc>().add(
                      UpdateApplicationStatus(application.id, status),
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? const Color(0xFFFCE8E6)
                  : const Color(0xFF4F46E5),
              foregroundColor: isDestructive
                  ? const Color(0xFFC5221F)
                  : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              statusLabel(status),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          );
        }).toList(),
      ),
    );
  }
}
