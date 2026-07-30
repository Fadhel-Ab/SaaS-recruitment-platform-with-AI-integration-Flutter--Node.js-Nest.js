import 'package:frontend/features/dashboard/data/model/dashboard_summary.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState {
  final DashboardStatus status;

  final DashboardSummary? summary;

  final String? error;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.error,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummary? summary,
    String? error,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      error: error ?? this.error,
    );
  }
}
