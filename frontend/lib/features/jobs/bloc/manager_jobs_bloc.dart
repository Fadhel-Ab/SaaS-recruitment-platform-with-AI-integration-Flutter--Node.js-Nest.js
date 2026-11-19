import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';

import '../data/jobs_repository.dart';

import 'manager_jobs_event.dart';
import 'manager_jobs_state.dart';

class ManagerJobsBloc extends Bloc<ManagerJobsEvent, ManagerJobsState> {
  final JobsRepository repository;

  ManagerJobsBloc(this.repository) : super(const ManagerJobsState()) {
    on<LoadManagerJobs>(_load);
    on<DeleteManagerJob>(_delete);
  }

  FutureOr<void> _delete(
    DeleteManagerJob event,
    Emitter<ManagerJobsState> emit,
  ) async {
    // Ignore taps while another delete is still in flight.
    if (state.deletingJobId != null) return;

    emit(state.copyWith(deletingJobId: event.jobId));

    try {
      await repository.deleteJob(event.jobId);

      // Remove it locally instead of reloading the whole list.
      emit(
        state.copyWith(
          jobs: state.jobs.where((job) => job.id != event.jobId).toList(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(actionError: friendlyErrorMessage(e)));
    }
  }

  FutureOr<void> _load(
    LoadManagerJobs event,
    Emitter<ManagerJobsState> emit,
  ) async {
    emit(state.copyWith(status: ManagerJobsStatus.loading));

    try {
      final jobs = await repository.getMyJobs();

      emit(state.copyWith(status: ManagerJobsStatus.success, jobs: jobs));
    } catch (e) {
      emit(
        state.copyWith(status: ManagerJobsStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }
}
