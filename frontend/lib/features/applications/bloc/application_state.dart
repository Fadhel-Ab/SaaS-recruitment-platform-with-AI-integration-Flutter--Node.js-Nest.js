enum ApplicationStatus { initial, uploading, submitting, success, failure }

class ApplicationState {
  final ApplicationStatus status;

  final String? fileName;

  final String? error;

  const ApplicationState({
    this.status = ApplicationStatus.initial,
    this.fileName,
    this.error,
  });

  ApplicationState copyWith({
    ApplicationStatus? status,
    String? fileName,
    String? error,
  }) {
    return ApplicationState(
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      error: error ?? this.error,
    );
  }
}
