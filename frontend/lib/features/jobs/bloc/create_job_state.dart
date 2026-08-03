import 'package:frontend/features/availability/model/availability_slot.dart';

import '../models/create_job_request.dart';

enum CreateJobStatus {
  initial,
  generatingQuestions,
  questionsReady,
  loadingAvailabilityDefaults,
  availabilityReady,
  submitting,
  success,
  failure,
}

class CreateJobState {
  final CreateJobStatus status;
  final String? error;
  final List<String> questions;
  final List<String> approvedQuestions;
  final List<AvailabilitySlot> defaultAvailability;
  final CreateJobRequest? pendingJob;

  const CreateJobState({
    this.status = CreateJobStatus.initial,
    this.error,
    this.questions = const [],
    this.approvedQuestions = const [],
    this.defaultAvailability = const [],
    this.pendingJob,
  });

  CreateJobState copyWith({
    CreateJobStatus? status,
    String? error,
    List<String>? questions,
    List<String>? approvedQuestions,
    List<AvailabilitySlot>? defaultAvailability,
    CreateJobRequest? pendingJob,
  }) {
    return CreateJobState(
      status: status ?? this.status,
      error: error ?? this.error,
      questions: questions ?? this.questions,
      approvedQuestions: approvedQuestions ?? this.approvedQuestions,
      defaultAvailability: defaultAvailability ?? this.defaultAvailability,
      pendingJob: pendingJob ?? this.pendingJob,
    );
  }
}
