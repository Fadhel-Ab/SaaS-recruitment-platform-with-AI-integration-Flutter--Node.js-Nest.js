import 'package:frontend/features/applications/model/pipeline_entry.dart';

enum PipelineStatus { initial, loading, success, failure }

class PipelineState {
  final PipelineStatus status;
  final List<PipelineEntry> entries;
  final String? error;

  const PipelineState({
    this.status = PipelineStatus.initial,
    this.entries = const [],
    this.error,
  });

  PipelineState copyWith({
    PipelineStatus? status,
    List<PipelineEntry>? entries,
    String? error,
  }) {
    return PipelineState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      error: error ?? this.error,
    );
  }
}
