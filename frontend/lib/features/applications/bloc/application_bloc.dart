import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';
import 'package:frontend/features/applications/bloc/application_event.dart';
import 'package:frontend/features/applications/bloc/application_state.dart';
import 'package:frontend/features/applications/data/application_repository.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ApplicationRepository repository;
  final JobsRepository jobsRepository;
  ApplicationBloc(this.repository, this.jobsRepository)
    : super(const ApplicationState()) {
    on<UploadCvRequested>(_upload);
    on<SubmitApplicationRequested>(_submit);
    on<LoadApplicationJob>(_loadJob);
  }

  FutureOr<void> _upload(
    UploadCvRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(state.copyWith(status: ApplicationStatus.uploading));
    try {
      final result = await repository.uploadCv(
        path: event.path,
        bytes: event.bytes,
        fileName: event.fileName,
      );

      emit(state.copyWith(status: ApplicationStatus.success, fileName: result));
    } catch (e) {
      emit(
        state.copyWith(status: ApplicationStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }

  FutureOr<void> _submit(
    SubmitApplicationRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(state.copyWith(status: ApplicationStatus.submitting));
    try {
      final result = await repository.submitApplication(
        event.shareToken,
        event.request,
      );
      emit(state.copyWith(status: ApplicationStatus.success, result: result));
    } catch (e) {
      emit(
        state.copyWith(status: ApplicationStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }

  Future<void> _loadJob(
    LoadApplicationJob event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(state.copyWith(status: ApplicationStatus.loadingJob));

    try {
      final job = await jobsRepository.getJob(event.shareToken);

      emit(state.copyWith(status: ApplicationStatus.initial, job: job));
    } catch (e) {
      emit(
        state.copyWith(status: ApplicationStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }
}
