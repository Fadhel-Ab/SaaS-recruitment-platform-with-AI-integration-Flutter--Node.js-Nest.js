class CreateJobRequest {
  final String title;
  final String description;
  final String requirements;
  final String employmentType;
  final String companyName;
  final String skillLevel;
  final String location;
  final List<String>? interviewQuestions;

  CreateJobRequest({
    required this.title,
    required this.description,
    required this.requirements,
    required this.employmentType,
    required this.companyName,
    required this.skillLevel,
    required this.location,
    this.interviewQuestions,
  });

  CreateJobRequest copyWith({List<String>? interviewQuestions}) {
    return CreateJobRequest(
      title: title,
      description: description,
      requirements: requirements,
      employmentType: employmentType,
      companyName: companyName,
      skillLevel: skillLevel,
      location: location,
      interviewQuestions: interviewQuestions ?? this.interviewQuestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'employmentType': employmentType,
      'companyName': companyName,
      'skillLevel': skillLevel,
      'location': location,
      if (interviewQuestions != null) 'interviewQuestions': interviewQuestions,
    };
  }
}
