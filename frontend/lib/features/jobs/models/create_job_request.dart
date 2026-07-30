class CreateJobRequest {
  final String title;
  final String description;
  final String requirements;
  final String employmentType;
  final String companyName;
  final String skillLevel;

  CreateJobRequest({
    required this.title,
    required this.description,
    required this.requirements,
    required this.employmentType,
    required this.companyName,
    required this.skillLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'employmentType': employmentType,
      'companyName': companyName,
      'skillLevel': skillLevel,
    };
  }
}
