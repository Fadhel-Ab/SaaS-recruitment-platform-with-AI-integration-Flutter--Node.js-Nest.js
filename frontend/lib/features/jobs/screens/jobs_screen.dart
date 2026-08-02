import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      // Drawer filter for mobile screens
      endDrawer: MediaQuery.of(context).size.width <= 900
          ? const Drawer(child: SafeArea(child: JobsFilterPanel()))
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
              const SizedBox(height: 20),

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
                          const JobsFilterPanel(),
                          const SizedBox(width: 24),
                        ],

                        // Main Content Area
                        Expanded(
                          child: Column(
                            children: [
                              _buildSearchBar(isDesktop: isDesktop),
                              const SizedBox(height: 16),
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

  Widget _buildUrgentPinnedJobs(List jobs, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.push_pin_outlined, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text('Urgent pinned jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF9A3412))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isDesktop ? 180 : 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return SizedBox(
                width: isDesktop ? 360 : 300,
                child: Card(
                  elevation: 0,
                  color: const Color(0xFFFFF7ED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFFDBA74)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.go('/jobs/${job.shareToken}'),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Chip(
                            label: Text('URGENT'),
                            avatar: Icon(Icons.local_fire_department, size: 16),
                            backgroundColor: Color(0xFFFED7AA),
                            labelStyle: TextStyle(color: Color(0xFF9A3412), fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text(job.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF7C2D12))),
                          const SizedBox(height: 8),
                          Text('${job.company ?? 'TalentHQ'} • ${job.location}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFC2410C))),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search jobs by title, skills, or location...',
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

            final urgentJobs = state.jobs.where((job) => job.isUrgent || job.isPinned).toList();
            final regularJobs = state.jobs.where((job) => !urgentJobs.contains(job)).toList();

            return ListView.separated(
              itemCount: regularJobs.length + (urgentJobs.isNotEmpty ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (urgentJobs.isNotEmpty && index == 0) {
                  return _buildUrgentPinnedJobs(urgentJobs, isDesktop: isDesktop);
                }
                final job = regularJobs[index - (urgentJobs.isNotEmpty ? 1 : 0)];
                return JobCard(
                  job: job,
                  index: index,
                  isDesktop: isDesktop,
                  onTap: () {
                    context.go('/jobs/${job.shareToken}');
                  },
                );
              },
            );

          default:
            return const SizedBox();
        }
      },
    );
  }
}
