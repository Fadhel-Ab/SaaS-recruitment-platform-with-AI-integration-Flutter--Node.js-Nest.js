import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/jobs/bloc/jobs_event.dart';
import 'package:frontend/features/jobs/bloc/jobs_state.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final JobsRepository repository;

  JobsBloc(this.repository) : super(const JobsState()) {
    on<LoadJobs>(_loadJobs);
  }

  FutureOr<void> _loadJobs(LoadJobs event, Emitter<JobsState> emit) async {
    emit(state.copyWith(status: JobsStatus.loading));

    try {
      final result = await repository.getJobs();
      emit(state.copyWith(jobs: result, status: JobsStatus.loaded));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: JobsStatus.failure));
    }
  }
}
