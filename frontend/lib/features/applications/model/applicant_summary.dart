class ApplicantSummary {
  final String id;
  final String candidateId;
  final String candidateName;
  final String candidateEmail;
  final String candidatePhone;
  final String status;
  final DateTime appliedAt;
  final double? cvScore;
  final double? interviewScore;
  final double? overallScore;

  const ApplicantSummary({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.candidateEmail,
    required this.candidatePhone,
    required this.status,
    required this.appliedAt,
    this.cvScore,
    this.interviewScore,
    this.overallScore,
  });

  factory ApplicantSummary.fromJson(Map<String, dynamic> json) {
    final candidate = json['candidate'] as Map<String, dynamic>? ?? {};
    final aiScore = json['aiScore'] as Map<String, dynamic>?;

    return ApplicantSummary(
      id: json['id'] ?? '',
      candidateId: candidate['id'] ?? '',
      candidateName: candidate['fullName'] ?? 'Unknown Candidate',
      candidateEmail: candidate['email'] ?? '',
      candidatePhone: candidate['phone'] ?? '',
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
