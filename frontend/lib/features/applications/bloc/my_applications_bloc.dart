import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';

import '../data/application_repository.dart';
import 'my_applications_event.dart';
import 'my_applications_state.dart';

class MyApplicationsBloc
    extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  final ApplicationRepository repository;

  MyApplicationsBloc(this.repository) : super(const MyApplicationsState()) {
    on<LoadMyApplications>(_load);
  }

  FutureOr<void> _load(
    LoadMyApplications event,
    Emitter<MyApplicationsState> emit,
  ) async {
    emit(state.copyWith(status: MyApplicationsStatus.loading));

    try {
      final applications = await repository.getMyApplications();

      emit(
        state.copyWith(
          status: MyApplicationsStatus.success,
          applications: applications,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MyApplicationsStatus.failure,
          error: friendlyErrorMessage(e),
        ),
      );
    }
  }
}
