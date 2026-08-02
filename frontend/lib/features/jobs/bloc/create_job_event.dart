import '../models/create_job_request.dart';

abstract class CreateJobEvent {}

class GenerateQuestionsRequested extends CreateJobEvent {
  final CreateJobRequest details;

  GenerateQuestionsRequested(this.details);
}

class PublishJobRequested extends CreateJobEvent {
  final List<String> approvedQuestions;

  PublishJobRequested(this.approvedQuestions);
}

class BackToJobDetailsRequested extends CreateJobEvent {}
