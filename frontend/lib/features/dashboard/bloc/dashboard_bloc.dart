import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';

import '../data/dashboard_repository.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(const DashboardState()) {
    on<LoadDashboard>(_loadDashboard);
  }

  FutureOr<void> _loadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      final summary = await repository.getSummary();

      emit(state.copyWith(status: DashboardStatus.success, summary: summary));
    } catch (e) {
      emit(
        state.copyWith(status: DashboardStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }
}
