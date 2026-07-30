class DashboardSummary {
  final int activeJobs;
  final int totalApplications;
  final int pendingApplications;
  final int shortlisted;
  final int aiInterviews;
  final int completedAIInterviews;
  final int interviewsScheduled;
  final int interviewsCompleted;
  final int offers;
  final int hired;
  final int rejected;
  final double averageAIScore;

  DashboardSummary({
    required this.activeJobs,
    required this.totalApplications,
    required this.pendingApplications,
    required this.shortlisted,
    required this.interviewsScheduled,
    required this.interviewsCompleted,
    required this.aiInterviews,
    required this.completedAIInterviews,
    required this.offers,
    required this.hired,
    required this.rejected,
    required this.averageAIScore,
  });
  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeJobs: json['activeJobs'] ?? 0,
      totalApplications: json['totalApplications'] ?? 0,
      pendingApplications: json['pendingApplications'] ?? 0,
      shortlisted: json['shortlisted'] ?? 0,

      aiInterviews: json['aiInterviews'] ?? 0,
      completedAIInterviews: json['completedAIInterviews'] ?? 0,

      interviewsScheduled: json['scheduledInterviews'] ?? 0,

      interviewsCompleted: json['completedInterviews'] ?? 0,

      offers: json['offers'] ?? 0,
      hired: json['hired'] ?? 0,
      rejected: json['rejected'] ?? 0,

      averageAIScore: (json['averageAIScore'] ?? 0).toDouble(),
    );
  }
}
