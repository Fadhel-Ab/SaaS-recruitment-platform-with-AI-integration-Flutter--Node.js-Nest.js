import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/jobs_repository.dart';

import 'create_job_event.dart';
import 'create_job_state.dart';

class CreateJobBloc extends Bloc<CreateJobEvent, CreateJobState> {
  final JobsRepository repository;

  CreateJobBloc(this.repository) : super(const CreateJobState()) {
    on<GenerateQuestionsRequested>(_generateQuestions);
    on<PublishJobRequested>(_publish);
    on<BackToJobDetailsRequested>(_back);
  }

  FutureOr<void> _generateQuestions(
    GenerateQuestionsRequested event,
    Emitter<CreateJobState> emit,
  ) async {
    emit(state.copyWith(status: CreateJobStatus.generatingQuestions));

    try {
      final questions = await repository.generateInterviewQuestions(
        event.details,
      );

      emit(
        state.copyWith(
          status: CreateJobStatus.questionsReady,
          questions: questions,
          pendingJob: event.details,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CreateJobStatus.failure, error: e.toString()),
      );
    }
  }

  FutureOr<void> _publish(
    PublishJobRequested event,
    Emitter<CreateJobState> emit,
  ) async {
    final pendingJob = state.pendingJob;
    if (pendingJob == null) return;

    emit(state.copyWith(status: CreateJobStatus.submitting));

    try {
      await repository.createJob(
        pendingJob.copyWith(interviewQuestions: event.approvedQuestions),
      );

      emit(state.copyWith(status: CreateJobStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: CreateJobStatus.failure, error: e.toString()),
      );
    }
  }

  FutureOr<void> _back(
    BackToJobDetailsRequested event,
    Emitter<CreateJobState> emit,
  ) {
    emit(state.copyWith(status: CreateJobStatus.initial));
  }
}
