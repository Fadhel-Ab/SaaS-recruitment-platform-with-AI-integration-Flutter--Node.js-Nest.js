import 'package:frontend/features/jobs/models/job_model.dart';

enum ApplicationStatus {
  initial,
  loadingJob,
  uploading,
  submitting,
  success,
  failure,
}

class ApplicationState {
  final ApplicationStatus status;
  final String? fileName;
  final JobModel? job;
  final String? error;

  const ApplicationState({
    this.status = ApplicationStatus.initial,
    this.fileName,
    this.job,
    this.error,
  });

  ApplicationState copyWith({
    ApplicationStatus? status,
    String? fileName,
    JobModel? job,
    String? error,
  }) {
    return ApplicationState(
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      job: job ?? this.job,
      error: error ?? this.error,
    );
  }
}
