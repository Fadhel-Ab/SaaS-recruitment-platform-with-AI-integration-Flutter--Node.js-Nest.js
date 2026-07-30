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
  final DateTime createdAt; // Added field

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.employmentType,
    required this.shareToken,
    required this.createdAt,
    required this.skillLevel, // Added to constructor
    this.company,
    required this.applications,
    this.interviews,
    this.status,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      requirements: json['requirements'],
      location: json['location'],
      employmentType: json['employmentType'],
      shareToken: json['shareToken'],
      company: json['company'],
      applications: json['_count']?['applications'] ?? 0,
      skillLevel: json["skillLevel"],
      interviews: int.tryParse(json['interviews'] ?? ''),
      status: json['status'],

      // Parses ISO 8601 string or falls back to current time if missing
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
