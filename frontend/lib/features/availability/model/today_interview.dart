class TodayInterview {
  final String id;
  final String applicationId;
  final DateTime? scheduledAt;
  final int duration;
  final String? meetingLink;
  final String status;
  final String candidateName;
  final String candidateEmail;
  final String candidatePhone;
  final String jobTitle;

  const TodayInterview({
    required this.id,
    required this.applicationId,
    this.scheduledAt,
    required this.duration,
    this.meetingLink,
    required this.status,
    required this.candidateName,
    required this.candidateEmail,
    required this.candidatePhone,
    required this.jobTitle,
  });

  factory TodayInterview.fromJson(Map<String, dynamic> json) {
    return TodayInterview(
      id: json['id'] ?? '',
      applicationId: json['applicationId'] ?? '',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      duration: (json['duration'] as num?)?.toInt() ?? 30,
      meetingLink: json['meetingLink'],
      status: json['status'] ?? 'SCHEDULED',
      candidateName: json['candidateName'] ?? 'Unknown Candidate',
      candidateEmail: json['candidateEmail'] ?? '',
      candidatePhone: json['candidatePhone'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
    );
  }
}
