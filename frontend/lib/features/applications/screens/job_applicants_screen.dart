import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/features/applications/bloc/job_applicants_bloc.dart';
import 'package:frontend/features/applications/bloc/job_applicants_event.dart';
import 'package:frontend/features/applications/bloc/job_applicants_state.dart';
import 'package:frontend/features/applications/data/application_repository.dart';
import 'package:frontend/features/applications/model/applicant_summary.dart';
import 'package:frontend/features/applications/model/application_status.dart';

enum _SortOption { latest, highestScore, oldest }

class JobApplicantsScreen extends StatefulWidget {
  final String jobId;
  final String? jobTitle;

  const JobApplicantsScreen({super.key, required this.jobId, this.jobTitle});

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  final Set<String> _selectedStatuses = {};
  RangeValues _scoreRange = const RangeValues(0, 100);
  _SortOption _sort = _SortOption.latest;

  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  bool _isBulkUpdating = false;

  List<ApplicantSummary> _apply(List<ApplicantSummary> applicants) {
    final filtered = applicants.where((applicant) {
      final matchesStatus =
          _selectedStatuses.isEmpty ||
          _selectedStatuses.contains(applicant.status);

      final score = applicant.overallScore;
      final matchesScore =
          score == null ||
          (score >= _scoreRange.start && score <= _scoreRange.end);

      return matchesStatus && matchesScore;
    }).toList();

    switch (_sort) {
      case _SortOption.latest:
        filtered.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        break;
      case _SortOption.oldest:
        filtered.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
        break;
      case _SortOption.highestScore:
        filtered.sort(
          (a, b) => (b.overallScore ?? -1).compareTo(a.overallScore ?? -1),
        );
        break;
    }

    return filtered;
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) _selectedIds.clear();
    });
  }

  Future<void> _bulkUpdate(String status) async {
    if (_selectedIds.isEmpty || _isBulkUpdating) return;

    setState(() => _isBulkUpdating = true);
    try {
      final (updated, skipped) = await context
          .read<ApplicationRepository>()
          .bulkUpdateStatus(_selectedIds.toList(), status);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            skipped == 0
                ? 'Updated $updated candidate(s)'
                : 'Updated $updated candidate(s), skipped $skipped (invalid transition)',
          ),
        ),
      );

      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
      context.read<JobApplicantsBloc>().add(LoadJobApplicants(widget.jobId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bulk update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBulkUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          widget.jobTitle != null ? 'Candidates — ${widget.jobTitle}' : 'Candidates',
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _selectionMode ? 'Cancel selection' : 'Select candidates',
            icon: Icon(
              _selectionMode ? Icons.close : Icons.checklist,
              color: _selectionMode ? const Color(0xFF4F46E5) : null,
            ),
            onPressed: _toggleSelectionMode,
          ),
        ],
      ),
      body: BlocBuilder<JobApplicantsBloc, JobApplicantsState>(
        builder: (context, state) {
          if (state.status == JobApplicantsStatus.loading ||
              state.status == JobApplicantsStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (state.status == JobApplicantsStatus.failure) {
            return Center(
              child: Text(
                state.error ?? 'Failed to load candidates',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          if (state.applicants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 60,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          final filtered = _apply(state.applicants);

          return Column(
            children: [
              _FilterBar(
                selectedStatuses: _selectedStatuses,
                scoreRange: _scoreRange,
                sort: _sort,
                onStatusToggled: (status) => setState(() {
                  if (_selectedStatuses.contains(status)) {
                    _selectedStatuses.remove(status);
                  } else {
                    _selectedStatuses.add(status);
                  }
                }),
                onScoreRangeChanged: (range) =>
                    setState(() => _scoreRange = range),
                onSortChanged: (sort) => setState(() => _sort = sort),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No candidates match your filters',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final applicant = filtered[index];
                          return _ApplicantCard(
                            applicant: applicant,
                            selectionMode: _selectionMode,
                            selected: _selectedIds.contains(applicant.id),
                            onTap: () {
                              if (_selectionMode) {
                                setState(() {
                                  if (_selectedIds.contains(applicant.id)) {
                                    _selectedIds.remove(applicant.id);
                                  } else {
                                    _selectedIds.add(applicant.id);
                                  }
                                });
                              } else {
                                context.push(
                                  '/manager/applications/${applicant.id}',
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
              if (_selectionMode && _selectedIds.isNotEmpty)
                _BulkActionBar(
                  count: _selectedIds.length,
                  isUpdating: _isBulkUpdating,
                  onShortlist: () => _bulkUpdate('SHORTLISTED'),
                  onReject: () => _bulkUpdate('REJECTED'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  final int count;
  final bool isUpdating;
  final VoidCallback onShortlist;
  final VoidCallback onReject;

  const _BulkActionBar({
    required this.count,
    required this.isUpdating,
    required this.onShortlist,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(
            '$count selected',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: isUpdating ? null : onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC5221F),
              side: const BorderSide(color: Color(0xFFC5221F)),
            ),
            child: const Text('Reject Selected'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isUpdating ? null : onShortlist,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Shortlist Selected'),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final Set<String> selectedStatuses;
  final RangeValues scoreRange;
  final _SortOption sort;
  final ValueChanged<String> onStatusToggled;
  final ValueChanged<RangeValues> onScoreRangeChanged;
  final ValueChanged<_SortOption> onSortChanged;

  const _FilterBar({
    required this.selectedStatuses,
    required this.scoreRange,
    required this.sort,
    required this.onStatusToggled,
    required this.onScoreRangeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allowedStatusTransitions.keys.map((status) {
                    final isSelected = selectedStatuses.contains(status);
                    return FilterChip(
                      label: Text(statusLabel(status)),
                      selected: isSelected,
                      onSelected: (_) => onStatusToggled(status),
                      selectedColor: const Color(0xFFEEF2FF),
                      checkmarkColor: const Color(0xFF4F46E5),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF374151),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      backgroundColor: Colors.white,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<_SortOption>(
                value: sort,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: _SortOption.latest,
                    child: Text('Latest'),
                  ),
                  DropdownMenuItem(
                    value: _SortOption.highestScore,
                    child: Text('Highest Score'),
                  ),
                  DropdownMenuItem(
                    value: _SortOption.oldest,
                    child: Text('Oldest'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'AI Score',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              Expanded(
                child: RangeSlider(
                  values: scoreRange,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: const Color(0xFF4F46E5),
                  labels: RangeLabels(
                    scoreRange.start.round().toString(),
                    scoreRange.end.round().toString(),
                  ),
                  onChanged: onScoreRangeChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicantSummary applicant;
  final VoidCallback onTap;
  final bool selectionMode;
  final bool selected;

  const _ApplicantCard({
    required this.applicant,
    required this.onTap,
    this.selectionMode = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
          width: selected ? 1.5 : 1,
        ),
      ),
      color: selected ? const Color(0xFFF5F6FF) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (selectionMode) ...[
                Checkbox(
                  value: selected,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: (_) => onTap(),
                ),
                const SizedBox(width: 4),
              ],
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  applicant.candidateName.isNotEmpty
                      ? applicant.candidateName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.candidateName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      applicant.candidateEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (applicant.overallScore != null) ...[
                _ScorePill(score: applicant.overallScore!),
                const SizedBox(width: 12),
              ],
              _StatusPill(status: applicant.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final double score;

  const _ScorePill({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${score.round()}%',
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: colors.$2,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(String status) {
    switch (status) {
      case 'HIRED':
      case 'OFFERED':
        return (const Color(0xFFE6F4EA), const Color(0xFF137333));
      case 'REJECTED':
      case 'WITHDRAWN':
        return (const Color(0xFFFCE8E6), const Color(0xFFC5221F));
      case 'SHORTLISTED':
      case 'INTERVIEW_SCHEDULED':
      case 'INTERVIEW_COMPLETED':
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100));
      default:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
    }
  }
}
