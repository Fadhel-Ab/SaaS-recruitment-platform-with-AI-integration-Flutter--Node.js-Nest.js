import 'package:frontend/features/applications/model/my_application_summary.dart';

enum MyApplicationsStatus { initial, loading, success, failure }

class MyApplicationsState {
  final MyApplicationsStatus status;
  final List<MyApplicationSummary> applications;
  final String? error;

  const MyApplicationsState({
    this.status = MyApplicationsStatus.initial,
    this.applications = const [],
    this.error,
  });

  MyApplicationsState copyWith({
    MyApplicationsStatus? status,
    List<MyApplicationSummary>? applications,
    String? error,
  }) {
    return MyApplicationsState(
      status: status ?? this.status,
      applications: applications ?? this.applications,
      error: error ?? this.error,
    );
  }
}
