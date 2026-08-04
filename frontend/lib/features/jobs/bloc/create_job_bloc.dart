import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';

import '../data/jobs_repository.dart';

import 'create_job_event.dart';
import 'create_job_state.dart';

class CreateJobBloc extends Bloc<CreateJobEvent, CreateJobState> {
  final JobsRepository repository;

  CreateJobBloc(this.repository) : super(const CreateJobState()) {
    on<GenerateQuestionsRequested>(_generateQuestions);
    on<BackToJobDetailsRequested>(_backToDetails);
    on<QuestionsApproved>(_questionsApproved);
    on<BackToQuestionsRequested>(_backToQuestions);
    on<PublishJobRequested>(_publish);
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
        state.copyWith(status: CreateJobStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }

  FutureOr<void> _backToDetails(
    BackToJobDetailsRequested event,
    Emitter<CreateJobState> emit,
  ) {
    emit(state.copyWith(status: CreateJobStatus.initial));
  }

  FutureOr<void> _questionsApproved(
    QuestionsApproved event,
    Emitter<CreateJobState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CreateJobStatus.loadingAvailabilityDefaults,
        approvedQuestions: event.questions,
      ),
    );

    try {
      final defaults = await repository.getDefaultAvailability();

      emit(
        state.copyWith(
          status: CreateJobStatus.availabilityReady,
          defaultAvailability: defaults,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CreateJobStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }

  FutureOr<void> _backToQuestions(
    BackToQuestionsRequested event,
    Emitter<CreateJobState> emit,
  ) {
    emit(state.copyWith(status: CreateJobStatus.questionsReady));
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
        pendingJob.copyWith(
          interviewQuestions: state.approvedQuestions,
          availability: event.availability,
        ),
      );

      emit(state.copyWith(status: CreateJobStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: CreateJobStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }
}
