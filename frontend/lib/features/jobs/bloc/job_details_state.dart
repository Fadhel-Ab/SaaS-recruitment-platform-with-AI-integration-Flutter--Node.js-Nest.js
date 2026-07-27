import 'package:frontend/features/jobs/models/job_model.dart';

enum JobDetailsStatus { initial, loading, loaded, failure }

class JobDetailsState {
  final JobDetailsStatus status;
  final JobModel? job;
  final String? error;

  const JobDetailsState({
    this.status = JobDetailsStatus.initial,
    this.job,
    this.error,
  });

  JobDetailsState copyWith({
    JobDetailsStatus? status,
    JobModel? job,
    String? error,
  }) {
    return JobDetailsState(
      status: status ?? this.status,
      job: job ?? this.job,
      error: error ?? this.error,
    );
  }
}
