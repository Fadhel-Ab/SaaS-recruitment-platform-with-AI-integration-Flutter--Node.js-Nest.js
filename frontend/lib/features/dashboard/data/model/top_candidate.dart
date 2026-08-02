class TopCandidate {
  final String id;
  final String name;
  final String role;
  final int cvScore;
  final int? interviewScore;
  final String summary;

  TopCandidate({
    required this.id,
    required this.name,
    required this.role,
    required this.cvScore,
    this.interviewScore,
    required this.summary,
  });

  factory TopCandidate.fromJson(Map<String, dynamic> json) {
    return TopCandidate(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      cvScore: json['cvScore'] ?? 0,
      interviewScore: json['interviewScore'],
      summary: json['summary'] ?? '',
    );
  }
}
