import 'package:frontend/features/applications/model/applicant_summary.dart';

enum JobApplicantsStatus { initial, loading, success, failure }

class JobApplicantsState {
  final JobApplicantsStatus status;
  final List<ApplicantSummary> applicants;
  final String? error;

  const JobApplicantsState({
    this.status = JobApplicantsStatus.initial,
    this.applicants = const [],
    this.error,
  });

  JobApplicantsState copyWith({
    JobApplicantsStatus? status,
    List<ApplicantSummary>? applicants,
    String? error,
  }) {
    return JobApplicantsState(
      status: status ?? this.status,
      applicants: applicants ?? this.applicants,
      error: error ?? this.error,
    );
  }
}
