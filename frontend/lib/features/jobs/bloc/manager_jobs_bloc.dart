import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/jobs_repository.dart';

import 'manager_jobs_event.dart';
import 'manager_jobs_state.dart';

class ManagerJobsBloc extends Bloc<ManagerJobsEvent, ManagerJobsState> {
  final JobsRepository repository;

  ManagerJobsBloc(this.repository) : super(const ManagerJobsState()) {
    on<LoadManagerJobs>(_load);
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
        state.copyWith(status: ManagerJobsStatus.failure, error: e.toString()),
      );
    }
  }
}
