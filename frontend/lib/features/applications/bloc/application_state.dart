import 'package:frontend/features/applications/model/application_result.dart';
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
  final ApplicationResult? result;
  final String? error;

  const ApplicationState({
    this.status = ApplicationStatus.initial,
    this.fileName,
    this.job,
    this.result,
    this.error,
  });

  ApplicationState copyWith({
    ApplicationStatus? status,
    String? fileName,
    JobModel? job,
    ApplicationResult? result,
    String? error,
  }) {
    return ApplicationState(
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      job: job ?? this.job,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}
