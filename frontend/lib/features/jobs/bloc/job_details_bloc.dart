import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';
import 'package:frontend/features/jobs/bloc/job_details_event.dart';
import 'package:frontend/features/jobs/bloc/job_details_state.dart';
import 'package:frontend/features/jobs/data/jobs_repository.dart';

class JobDetailsBloc extends Bloc<JobDetailsEvent, JobDetailsState> {
  final JobsRepository repository;

  JobDetailsBloc(this.repository) : super(const JobDetailsState()) {
    on<LoadJobDetails>(_load);
  }

  Future<void> _load(
    LoadJobDetails event,
    Emitter<JobDetailsState> emit,
  ) async {
    emit(state.copyWith(status: JobDetailsStatus.loading));

    try {

      final job = await repository.getJob(event.shareToken);
      emit(state.copyWith(status: JobDetailsStatus.loaded, job: job));
    } catch (e) {
      emit(
        state.copyWith(status: JobDetailsStatus.failure, error: friendlyErrorMessage(e)),
      );
    }
  }
}
