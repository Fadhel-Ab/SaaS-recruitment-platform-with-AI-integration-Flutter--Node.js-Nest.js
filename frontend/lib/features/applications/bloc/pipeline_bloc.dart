import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';

import '../data/application_repository.dart';
import 'pipeline_event.dart';
import 'pipeline_state.dart';

class PipelineBloc extends Bloc<PipelineEvent, PipelineState> {
  final ApplicationRepository repository;

  PipelineBloc(this.repository) : super(const PipelineState()) {
    on<LoadPipeline>(_load);
  }

  FutureOr<void> _load(
    LoadPipeline event,
    Emitter<PipelineState> emit,
  ) async {
    emit(state.copyWith(status: PipelineStatus.loading));

    try {
      final entries = await repository.getPipeline();

      emit(
        state.copyWith(status: PipelineStatus.success, entries: entries),
      );
    } catch (e) {
      emit(
        state.copyWith(status: PipelineStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }
}
