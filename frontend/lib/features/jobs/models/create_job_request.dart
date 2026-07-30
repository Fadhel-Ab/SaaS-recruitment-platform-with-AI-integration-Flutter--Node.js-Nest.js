class CreateJobRequest {
  final String title;
  final String description;
  final String requirements;
  final String employmentType;
  final String companyName;
  final String skillLevel;
  final String location;

  CreateJobRequest({
    required this.title,
    required this.description,
    required this.requirements,
    required this.employmentType,
    required this.companyName,
    required this.skillLevel,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'employmentType': employmentType,
      'companyName': companyName,
      'skillLevel': skillLevel,
      'location': location,
    };
  }
}
