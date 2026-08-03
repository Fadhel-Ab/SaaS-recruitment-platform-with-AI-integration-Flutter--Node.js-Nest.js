import 'package:frontend/features/availability/model/availability_slot.dart';

class CreateJobRequest {
  final String title;
  final String description;
  final String requirements;
  final String employmentType;
  final String companyName;
  final String skillLevel;
  final String location;
  final bool isUrgent;
  final List<String>? interviewQuestions;
  final List<AvailabilitySlot>? availability;

  CreateJobRequest({
    required this.title,
    required this.description,
    required this.requirements,
    required this.employmentType,
    required this.companyName,
    required this.skillLevel,
    required this.location,
    this.isUrgent = false,
    this.interviewQuestions,
    this.availability,
  });

  CreateJobRequest copyWith({
    List<String>? interviewQuestions,
    List<AvailabilitySlot>? availability,
  }) {
    return CreateJobRequest(
      title: title,
      description: description,
      requirements: requirements,
      employmentType: employmentType,
      companyName: companyName,
      skillLevel: skillLevel,
      location: location,
      isUrgent: isUrgent,
      interviewQuestions: interviewQuestions ?? this.interviewQuestions,
      availability: availability ?? this.availability,
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
      'isUrgent': isUrgent,
      if (interviewQuestions != null) 'interviewQuestions': interviewQuestions,
      if (availability != null)
        'availability': availability!.map((a) => a.toJson()).toList(),
    };
  }
}
