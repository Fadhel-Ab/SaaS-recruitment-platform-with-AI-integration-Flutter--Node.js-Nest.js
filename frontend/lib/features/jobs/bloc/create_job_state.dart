enum CreateJobStatus { initial, submitting, success, failure }

class CreateJobState {
  final CreateJobStatus status;
  final String? error;

  const CreateJobState({this.status = CreateJobStatus.initial, this.error});

  CreateJobState copyWith({CreateJobStatus? status, String? error}) {
    return CreateJobState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
