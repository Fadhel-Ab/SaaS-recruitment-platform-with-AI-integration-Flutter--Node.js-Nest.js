import 'package:frontend/features/availability/model/availability_slot.dart';

import '../models/create_job_request.dart';

abstract class CreateJobEvent {}

class GenerateQuestionsRequested extends CreateJobEvent {
  final CreateJobRequest details;

  GenerateQuestionsRequested(this.details);
}

class BackToJobDetailsRequested extends CreateJobEvent {}

class QuestionsApproved extends CreateJobEvent {
  final List<String> questions;

  QuestionsApproved(this.questions);
}

class BackToQuestionsRequested extends CreateJobEvent {}

class PublishJobRequested extends CreateJobEvent {
  final List<AvailabilitySlot> availability;

  PublishJobRequested(this.availability);
}
