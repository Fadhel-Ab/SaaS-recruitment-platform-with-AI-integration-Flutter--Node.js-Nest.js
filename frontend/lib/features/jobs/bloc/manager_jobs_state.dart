import '../models/job_model.dart';


enum ManagerJobsStatus {
  initial,
  loading,
  success,
  failure,
}


class ManagerJobsState {

  final ManagerJobsStatus status;

  final List<JobModel> jobs;

  final String? error;


  const ManagerJobsState({
    this.status = ManagerJobsStatus.initial,
    this.jobs = const [],
    this.error,
  });


  ManagerJobsState copyWith({

    ManagerJobsStatus? status,

    List<JobModel>? jobs,

    String? error,

  }) {

    return ManagerJobsState(

      status: status ?? this.status,

      jobs: jobs ?? this.jobs,

      error: error ?? this.error,

    );

  }

}