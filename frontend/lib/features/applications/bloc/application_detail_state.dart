import 'package:frontend/features/applications/model/application_detail.dart';

enum ApplicationDetailStatus { initial, loading, success, failure }

class ApplicationDetailState {
  final ApplicationDetailStatus status;
  final ApplicationDetail? application;
  final String? error;
  final bool isUpdatingStatus;
  // One-shot error surfaced via a snackbar for a failed status change; unlike
  // [error] it must be explicitly clearable back to null.
  final String? updateError;

  const ApplicationDetailState({
    this.status = ApplicationDetailStatus.initial,
    this.application,
    this.error,
    this.isUpdatingStatus = false,
    this.updateError,
  });

  ApplicationDetailState copyWith({
    ApplicationDetailStatus? status,
    ApplicationDetail? application,
    String? error,
    bool? isUpdatingStatus,
    String? updateError,
    bool clearUpdateError = false,
  }) {
    return ApplicationDetailState(
      status: status ?? this.status,
      application: application ?? this.application,
      error: error ?? this.error,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      updateError: clearUpdateError ? null : (updateError ?? this.updateError),
    );
  }
}
