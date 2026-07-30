import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/jobs_repository.dart';

import 'create_job_event.dart';
import 'create_job_state.dart';

class CreateJobBloc extends Bloc<CreateJobEvent, CreateJobState> {
  final JobsRepository repository;

  CreateJobBloc(this.repository) : super(const CreateJobState()) {
    on<SubmitJobRequested>(_submit);
  }

  FutureOr<void> _submit(
    SubmitJobRequested event,
    Emitter<CreateJobState> emit,
  ) async {
    emit(state.copyWith(status: CreateJobStatus.submitting));

    try {
      await repository.createJob(event.request);

      emit(state.copyWith(status: CreateJobStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: CreateJobStatus.failure, error: e.toString()),
      );
    }
  }
}
