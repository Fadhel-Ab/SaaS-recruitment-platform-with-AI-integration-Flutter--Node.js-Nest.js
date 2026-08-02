import 'package:frontend/features/dashboard/data/model/top_candidate.dart';

class DashboardSummary {
  final int activeJobs;
  final int totalApplications;
  final int aiInterviews;
  final int completedAIInterviews;
  final int scheduledInterviews;
  final int completedInterviews;
  final double averageAIScore;
  final int pendingApplications;
  final int shortlisted;
  final int interviewsCompleted;
  final int hired;
  final int rejected;

  final List<TopCandidate> topCandidates;

  DashboardSummary({
    required this.activeJobs,
    required this.totalApplications,
    required this.aiInterviews,
    required this.completedAIInterviews,
    required this.scheduledInterviews,
    required this.completedInterviews,
    required this.averageAIScore,
    required this.topCandidates,
    required this.pendingApplications,
    required this.shortlisted,
    required this.interviewsCompleted,
    required this.hired,
    required this.rejected,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeJobs: json['activeJobs'] ?? 0,
      totalApplications: json['totalApplications'] ?? 0,

      aiInterviews: json['aiInterviews'] ?? 0,
      completedAIInterviews: json['completedAIInterviews'] ?? 0,
      scheduledInterviews: json['scheduledInterviews'] ?? 0,
      completedInterviews: json['completedInterviews'] ?? 0,

      averageAIScore: (json['averageAIScore'] ?? 0).toDouble(),

      topCandidates: (json['topCandidates'] as List? ?? [])
          .map((e) => TopCandidate.fromJson(e))
          .toList(),
      pendingApplications: json['pendingApplications'] ?? 0,
      shortlisted: json['shortlisted'] ?? 0,
      interviewsCompleted: json['completedInterviews'] ?? 0,
      hired: json['hired'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}
