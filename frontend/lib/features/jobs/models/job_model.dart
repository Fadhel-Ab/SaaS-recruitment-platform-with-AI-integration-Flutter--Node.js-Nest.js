class JobModel {
  final String id;
  final String title;
  final String description;
  final String requirements;
  final String location;
  final String employmentType;
  final String shareToken;
  final String? company;
  final int applications;
  final int? interviews;
  final String? skillLevel;
  final String? status;
  final DateTime createdAt;
  final bool isUrgent;
  final bool isPinned;
  final List<String> interviewQuestions;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.employmentType,
    required this.shareToken,
    required this.createdAt,
    required this.skillLevel,
    this.company,
    required this.applications,
    this.interviews,
    this.status,
    this.isUrgent = false,
    this.isPinned = false,
    this.interviewQuestions = const [],
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',

      location: json['location'] ?? '',

      employmentType: json['employmentType'] ?? '',

      shareToken: json['shareToken'] ?? '',

      company: json['companyName'] ?? json['company'],

      applications: json['_count']?['applications'] ?? 0,

      skillLevel: json['skillLevel'],

      interviews: json['interviews'] is int ? json['interviews'] : null,

      status: json['status'],

      isUrgent: json['isUrgent'] == true || json['urgent'] == true || (json['priority']?.toString().toLowerCase() == 'urgent') || (json['status']?.toString().toLowerCase().contains('urgent') ?? false),

      isPinned: json['isPinned'] == true || json['pinned'] == true,

      interviewQuestions: json['interviewQuestions'] is List
          ? List<String>.from(json['interviewQuestions'])
          : const [],

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
