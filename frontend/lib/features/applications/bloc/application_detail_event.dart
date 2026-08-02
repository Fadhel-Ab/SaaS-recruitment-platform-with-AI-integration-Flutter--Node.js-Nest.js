abstract class ApplicationDetailEvent {}

class LoadApplicationDetail extends ApplicationDetailEvent {
  final String applicationId;

  LoadApplicationDetail(this.applicationId);
}

class UpdateApplicationStatus extends ApplicationDetailEvent {
  final String applicationId;
  final String status;

  UpdateApplicationStatus(this.applicationId, this.status);
}
