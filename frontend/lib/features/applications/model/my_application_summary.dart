class MyApplicationInterview {
  final DateTime? scheduledAt;
  final String? meetingLink;
  final String? status;

  const MyApplicationInterview({this.scheduledAt, this.meetingLink, this.status});

  factory MyApplicationInterview.fromJson(Map<String, dynamic> json) {
    return MyApplicationInterview(
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      meetingLink: json['meetingLink'],
      status: json['status'],
    );
  }
}

class MyApplicationSummary {
  final String id;
  final String jobTitle;
  final String companyName;
  final String? location;
  final String status;
  final DateTime appliedAt;
  final double? overallScore;
  final MyApplicationInterview? interview;

  const MyApplicationSummary({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    this.location,
    required this.status,
    required this.appliedAt,
    this.overallScore,
    this.interview,
  });

  factory MyApplicationSummary.fromJson(Map<String, dynamic> json) {
    final job = json['job'] as Map<String, dynamic>? ?? {};
    final aiScore = json['aiScore'] as Map<String, dynamic>?;
    final interviewJson = json['interview'] as Map<String, dynamic>?;

    return MyApplicationSummary(
      id: json['id'] ?? '',
      jobTitle: job['title'] ?? 'Unknown Role',
      companyName: job['companyName'] ?? 'Unknown Company',
      location: job['location'],
      status: json['status'] ?? 'PENDING',
      appliedAt:
          DateTime.tryParse(json['appliedAt']?.toString() ?? '') ??
          DateTime.now(),
      overallScore: (aiScore?['overallScore'] as num?)?.toDouble(),
      interview: interviewJson != null
          ? MyApplicationInterview.fromJson(interviewJson)
          : null,
    );
  }
}
