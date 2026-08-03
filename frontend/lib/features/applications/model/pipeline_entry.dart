class PipelineEntry {
  final String id;
  final String candidateId;
  final String candidateName;
  final String candidateEmail;
  final String candidatePhone;
  final String jobId;
  final String jobTitle;
  final String status;
  final DateTime appliedAt;
  final double? cvScore;
  final double? interviewScore;
  final double? overallScore;

  const PipelineEntry({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.candidateEmail,
    required this.candidatePhone,
    required this.jobId,
    required this.jobTitle,
    required this.status,
    required this.appliedAt,
    this.cvScore,
    this.interviewScore,
    this.overallScore,
  });

  factory PipelineEntry.fromJson(Map<String, dynamic> json) {
    final candidate = json['candidate'] as Map<String, dynamic>? ?? {};
    final job = json['job'] as Map<String, dynamic>? ?? {};
    final aiScore = json['aiScore'] as Map<String, dynamic>?;

    return PipelineEntry(
      id: json['id'] ?? '',
      candidateId: candidate['id'] ?? '',
      candidateName: candidate['fullName'] ?? 'Unknown Candidate',
      candidateEmail: candidate['email'] ?? '',
      candidatePhone: candidate['phone'] ?? '',
      jobId: job['id'] ?? '',
      jobTitle: job['title'] ?? 'Unknown Role',
      status: json['status'] ?? 'PENDING',
      appliedAt:
          DateTime.tryParse(json['appliedAt']?.toString() ?? '') ??
          DateTime.now(),
      cvScore: (aiScore?['cvScore'] as num?)?.toDouble(),
      interviewScore: (aiScore?['interviewScore'] as num?)?.toDouble(),
      overallScore: (aiScore?['overallScore'] as num?)?.toDouble(),
    );
  }
}
