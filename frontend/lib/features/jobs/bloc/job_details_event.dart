abstract class JobDetailsEvent {}

class LoadJobDetails extends JobDetailsEvent {
  final String shareToken;

  LoadJobDetails(this.shareToken);
}
