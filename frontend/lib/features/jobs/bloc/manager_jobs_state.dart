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

  /// Id of the job currently being deleted (shows a spinner, blocks double taps).
  final String? deletingJobId;

  /// One-off error from an action like delete; shown as a snackbar so the
  /// job list stays visible.
  final String? actionError;


  const ManagerJobsState({
    this.status = ManagerJobsStatus.initial,
    this.jobs = const [],
    this.error,
    this.deletingJobId,
    this.actionError,
  });


  ManagerJobsState copyWith({

    ManagerJobsStatus? status,

    List<JobModel>? jobs,

    String? error,

    // These two are "set or clear" on every update, so a previous value
    // never sticks around by accident.
    String? deletingJobId,

    String? actionError,

  }) {

    return ManagerJobsState(

      status: status ?? this.status,

      jobs: jobs ?? this.jobs,

      error: error ?? this.error,

      deletingJobId: deletingJobId,

      actionError: actionError,

    );

  }

}
