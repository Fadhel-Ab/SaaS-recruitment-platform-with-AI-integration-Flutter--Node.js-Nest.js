abstract class JobApplicantsEvent {}

class LoadJobApplicants extends JobApplicantsEvent {
  final String jobId;

  LoadJobApplicants(this.jobId);
}
