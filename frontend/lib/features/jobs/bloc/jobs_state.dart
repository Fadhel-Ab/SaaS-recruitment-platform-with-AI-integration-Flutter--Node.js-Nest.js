import 'package:equatable/equatable.dart';
import 'package:frontend/features/jobs/models/job_model.dart';

enum JobsStatus { initial, loading, loaded, failure }

class JobsState extends Equatable {
  final JobsStatus status;
  final List<JobModel> jobs;
  final String? error;

  const JobsState({
    this.status = JobsStatus.initial,
    this.jobs = const [],
    this.error,
  });

  JobsState copyWith({
    JobsStatus? status,
    List<JobModel>? jobs,
    String? error,
  }) {
    return JobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, jobs, error];
}
