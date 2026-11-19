abstract class ManagerJobsEvent {}

class LoadManagerJobs extends ManagerJobsEvent {
  LoadManagerJobs();
}

class DeleteManagerJob extends ManagerJobsEvent {
  final String jobId;

  DeleteManagerJob(this.jobId);
}
