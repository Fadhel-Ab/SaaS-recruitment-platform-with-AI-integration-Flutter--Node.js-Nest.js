import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';

import '../data/application_repository.dart';
import 'application_detail_event.dart';
import 'application_detail_state.dart';

class ApplicationDetailBloc
    extends Bloc<ApplicationDetailEvent, ApplicationDetailState> {
  final ApplicationRepository repository;

  ApplicationDetailBloc(this.repository)
    : super(const ApplicationDetailState()) {
    on<LoadApplicationDetail>(_load);
    on<UpdateApplicationStatus>(_updateStatus);
  }

  FutureOr<void> _load(
    LoadApplicationDetail event,
    Emitter<ApplicationDetailState> emit,
  ) async {
    emit(state.copyWith(status: ApplicationDetailStatus.loading));

    try {
      final application = await repository.getApplicationDetails(
        event.applicationId,
      );

      emit(
        state.copyWith(
          status: ApplicationDetailStatus.success,
          application: application,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ApplicationDetailStatus.failure,
          error: friendlyErrorMessage(e),
        ),
      );
    }
  }

  FutureOr<void> _updateStatus(
    UpdateApplicationStatus event,
    Emitter<ApplicationDetailState> emit,
  ) async {
    emit(state.copyWith(isUpdatingStatus: true, clearUpdateError: true));

    try {
      final application = await repository.updateApplicationStatus(
        event.applicationId,
        event.status,
      );

      emit(
        state.copyWith(
          status: ApplicationDetailStatus.success,
          application: application,
          isUpdatingStatus: false,
          clearUpdateError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdatingStatus: false,
          updateError: friendlyErrorMessage(e),
        ),
      );
    }
  }
}
