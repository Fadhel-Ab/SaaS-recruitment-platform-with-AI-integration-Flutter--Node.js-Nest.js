class JobModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String employmentType;
  final String shareToken;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.employmentType,
    required this.shareToken,
  });

  factory JobModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return JobModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      employmentType: json['employmentType'],
      shareToken: json['shareToken'],
    );
  }
}