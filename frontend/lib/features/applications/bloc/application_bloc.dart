import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/applications/bloc/application_event.dart';
import 'package:frontend/features/applications/bloc/application_state.dart';
import 'package:frontend/features/applications/data/application_repository.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ApplicationRepository repository;
  ApplicationBloc(this.repository) : super(const ApplicationState()) {
    print('Application bloc works');
    on<UploadCvRequested>(_upload);
    on<SubmitApplicationRequested>(_submit);
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
        state.copyWith(status: ApplicationStatus.failure, error: e.toString()),
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
      emit(state.copyWith(status: ApplicationStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: ApplicationStatus.failure, error: e.toString()),
      );
    }
  }
}
