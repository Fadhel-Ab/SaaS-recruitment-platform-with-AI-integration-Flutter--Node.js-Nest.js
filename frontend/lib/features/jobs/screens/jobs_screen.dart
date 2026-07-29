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
                  context.push('/jobs/new');
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

            return ListView.separated(
              itemCount: state.jobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = state.jobs[index];
                return JobCard(
                  job: job,
                  index: index,
                  isDesktop: isDesktop,
                  onTap: () {
                    context.push('/jobs/${job.shareToken}');
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
