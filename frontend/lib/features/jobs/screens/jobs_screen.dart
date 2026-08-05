import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/jobs/models/job_model.dart';
import 'package:frontend/features/jobs/screens/widgets/page_header.dart';
import 'package:go_router/go_router.dart';

import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_state.dart';
import 'widgets/job_card.dart';
import 'widgets/jobs_filter_panel.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  static const int _jobsPerPage = 6;

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTypes = {};
  String _selectedLocation = 'All Locations';
  String _selectedSort = 'Newest first';
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _currentPage = 1;
    });
  }

  void _handleFiltersChanged(List<String> types, String? location) {
    setState(() {
      _selectedTypes
        ..clear()
        ..addAll(types);
      _selectedLocation = location ?? 'All Locations';
      _currentPage = 1;
    });
  }

  void _handleSortChanged(String sortOrder) {
    setState(() {
      _selectedSort = sortOrder;
      _currentPage = 1;
    });
  }

  String _normalizeType(dynamic type) {
    return type.toString().toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
  }

  List<JobModel> _filterJobs(List<JobModel> jobs) {
    final query = _searchController.text.trim().toLowerCase();

    return jobs.where((job) {
      final matchesSearch =
          query.isEmpty ||
          job.title.toString().toLowerCase().contains(query) ||
          job.description.toString().toLowerCase().contains(query) ||
          job.requirements.toString().toLowerCase().contains(query) ||
          job.location.toString().toLowerCase().contains(query) ||
          job.employmentType.toString().toLowerCase().contains(query) ||
          (job.company?.toString().toLowerCase().contains(query) ?? false) ||
          (job.skillLevel?.toString().toLowerCase().contains(query) ?? false);

      final matchesType =
          _selectedTypes.isEmpty ||
          _selectedTypes.any(
            (type) =>
                _normalizeType(job.employmentType) == _normalizeType(type),
          );

      final matchesLocation =
          _selectedLocation == 'All Locations' ||
          job.location.toString().toLowerCase().contains(
            _selectedLocation.toLowerCase(),
          );

      return matchesSearch && matchesType && matchesLocation;
    }).toList();
  }

  List<JobModel> _sortJobs(List<JobModel> jobs) {
    final sorted = [...jobs];
    sorted.sort((a, b) => _selectedSort == 'Oldest first'
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    final loadedJobs = context.watch<JobsBloc>().state.jobs;
    final availableLocations = <String>{
      'All Locations',
      ...loadedJobs.map((j) => j.location).where((l) => l.trim().isNotEmpty),
    }.toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      // Drawer filter for mobile screens
      endDrawer: MediaQuery.of(context).size.width <= 900
          ? Drawer(
              child: SafeArea(
                child: JobsFilterPanel(
                  selectedTypes: _selectedTypes,
                  selectedLocation: _selectedLocation,
                  selectedSort: _selectedSort,
                  locations: availableLocations,
                  onFilterChanged: _handleFiltersChanged,
                  onSortChanged: _handleSortChanged,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: isDesktop
              ? const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 20.0)
              : const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              PageHeader(
                title: 'Job Listings',
                subtitle: 'Manage and review active recruitment listings',
                buttonLabel: 'Post a New Job',
                isDesktop: isDesktop,
                onButtonPressed: () {
                  context.go('/manager/create-job');
                },
              ),
              // Layout Body (Sidebar + Main Content Grid)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 900;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Web/Desktop Modern Faceted Filter Panel on the left
                        if (isDesktop) ...[
                          JobsFilterPanel(
                            selectedTypes: _selectedTypes,
                            selectedLocation: _selectedLocation,
                            selectedSort: _selectedSort,
                            locations: availableLocations,
                            onFilterChanged: _handleFiltersChanged,
                            onSortChanged: _handleSortChanged,
                          ),
                          const SizedBox(width: 18),
                        ],

                        // Main Content Area
                        Expanded(
                          child: Column(
                            children: [
                              _buildSearchBar(isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 12 : 8),
                              Expanded(
                                child: _buildJobList(isDesktop: isDesktop),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentPinnedJobs(
    List<JobModel> jobs, {
    required bool isDesktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.push_pin_outlined, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text(
              'Urgent pinned jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF9A3412),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isDesktop ? 180 : 170,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Size cards so exactly 2 are visible at once; the rest are
              // reachable by scrolling horizontally.
              const spacing = 12.0;
              const minCardWidth = 240.0;
              double cardWidth = jobs.length == 1
                  ? constraints.maxWidth.clamp(0, 420)
                  : (constraints.maxWidth - spacing) / 2;
              if (jobs.length > 1 && cardWidth < minCardWidth) {
                cardWidth = minCardWidth;
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return SizedBox(
                    width: cardWidth,
                    child: Card(
                      elevation: 0,
                      color: const Color(0xFFFFF7ED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFFDBA74)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/jobs/${job.shareToken}'),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Chip(
                                label: Text('URGENT'),
                                avatar: Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                ),
                                backgroundColor: Color(0xFFFED7AA),
                                labelStyle: TextStyle(
                                  color: Color(0xFF9A3412),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                job.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7C2D12),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${job.company ?? 'TalentHQ'} • ${job.location}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar({required bool isDesktop}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 14 : 10,
                ),
                hintText: isDesktop
                    ? 'Search jobs by title, skills, or location...'
                    : 'Search jobs...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          if (!isDesktop) ...[
            const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
            Builder(
              builder: (scaffoldContext) => IconButton(
                icon: const Icon(Icons.tune_rounded, color: Color(0xFF4F46E5)),
                onPressed: () {
                  Scaffold.of(scaffoldContext).openEndDrawer();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination({
    required int currentPage,
    required int totalPages,
    required int totalJobs,
    required int startIndex,
    required int visibleCount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${startIndex + 1}-${startIndex + visibleCount} of $totalJobs jobs',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous page',
                onPressed: currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Page $currentPage of $totalPages',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              IconButton(
                tooltip: 'Next page',
                onPressed: currentPage < totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobList({required bool isDesktop}) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        switch (state.status) {
          case JobsStatus.loading:
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );

          case JobsStatus.failure:
            return Center(
              child: Text(
                state.error ?? 'Error loading jobs',
                style: const TextStyle(color: Colors.red),
              ),
            );

          case JobsStatus.loaded:
            if (state.jobs.isEmpty) {
              return const Center(child: Text('No jobs found'));
            }

            final filteredJobs = _sortJobs(_filterJobs(state.jobs));
            if (filteredJobs.isEmpty) {
              return const Center(
                child: Text('No jobs match your search or filters'),
              );
            }

            // Urgent jobs are pinned in their own strip above the paginated
            // list (sourced from the full filtered set, not just the
            // current page) and excluded from the regular list below.
            final urgentJobs = filteredJobs
                .where((job) => job.isUrgent)
                .toList();
            final regularJobs = filteredJobs
                .where((job) => !job.isUrgent)
                .toList();

            final totalPages = regularJobs.isEmpty
                ? 1
                : (regularJobs.length / _jobsPerPage).ceil();
            final safePage = _currentPage.clamp(1, totalPages);
            final startIndex = (safePage - 1) * _jobsPerPage;
            final pagedJobs = regularJobs
                .skip(startIndex)
                .take(_jobsPerPage)
                .toList();

            return Column(
              children: [
                if (urgentJobs.length > 1) ...[
                  _buildUrgentPinnedJobs(urgentJobs, isDesktop: isDesktop),
                  const SizedBox(height: 16),
                ] else if (urgentJobs.length == 1) ...[
                  JobCard(
                    job: urgentJobs.first,
                    index: 0,
                    isDesktop: isDesktop,
                    onTap: () => context.push('/jobs/${urgentJobs.first.shareToken}'),
                  ),
                ],
                if (regularJobs.isNotEmpty) ...[
                  Expanded(
                    child: ListView.separated(
                      itemCount: pagedJobs.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: isDesktop ? 12 : 6),
                      itemBuilder: (context, index) {
                        final job = pagedJobs[index];
                        return JobCard(
                          job: job,
                          index: startIndex + index,
                          isDesktop: isDesktop,
                          onTap: () {
                            context.push('/jobs/${job.shareToken}');
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPagination(
                    currentPage: safePage,
                    totalPages: totalPages,
                    totalJobs: regularJobs.length,
                    startIndex: startIndex,
                    visibleCount: pagedJobs.length,
                  ),
                ],
              ],
            );

          default:
            return const SizedBox();
        }
      },
    );
  }
}
