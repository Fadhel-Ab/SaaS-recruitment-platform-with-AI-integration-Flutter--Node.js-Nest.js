import '../models/create_job_request.dart';

enum CreateJobStatus {
  initial,
  generatingQuestions,
  questionsReady,
  submitting,
  success,
  failure,
}

class CreateJobState {
  final CreateJobStatus status;
  final String? error;
  final List<String> questions;
  final CreateJobRequest? pendingJob;

  const CreateJobState({
    this.status = CreateJobStatus.initial,
    this.error,
    this.questions = const [],
    this.pendingJob,
  });

  CreateJobState copyWith({
    CreateJobStatus? status,
    String? error,
    List<String>? questions,
    CreateJobRequest? pendingJob,
  }) {
    return CreateJobState(
      status: status ?? this.status,
      error: error ?? this.error,
      questions: questions ?? this.questions,
      pendingJob: pendingJob ?? this.pendingJob,
    );
  }
}
