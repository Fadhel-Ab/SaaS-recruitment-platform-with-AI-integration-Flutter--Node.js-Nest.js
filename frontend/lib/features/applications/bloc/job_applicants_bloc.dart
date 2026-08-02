import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/application_repository.dart';
import 'job_applicants_event.dart';
import 'job_applicants_state.dart';

class JobApplicantsBloc extends Bloc<JobApplicantsEvent, JobApplicantsState> {
  final ApplicationRepository repository;

  JobApplicantsBloc(this.repository) : super(const JobApplicantsState()) {
    on<LoadJobApplicants>(_load);
  }

  FutureOr<void> _load(
    LoadJobApplicants event,
    Emitter<JobApplicantsState> emit,
  ) async {
    emit(state.copyWith(status: JobApplicantsStatus.loading));

    try {
      final applicants = await repository.getJobApplications(event.jobId);

      emit(
        state.copyWith(
          status: JobApplicantsStatus.success,
          applicants: applicants,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: JobApplicantsStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
