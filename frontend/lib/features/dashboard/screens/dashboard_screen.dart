import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:frontend/features/dashboard/bloc/dashboard_event.dart';
import 'package:frontend/features/dashboard/bloc/dashboard_state.dart';
import 'package:frontend/features/dashboard/screens/top_candidates_card.dart';
import 'package:go_router/go_router.dart';

// Import our decoupled sub-widgets
import 'widgets/metric_card.dart';
import 'widgets/pipeline_chart_card.dart';

String _trendText(int pct, String period) {
  if (pct > 0) return '↑ $pct% from $period';
  if (pct < 0) return '↓ ${pct.abs()}% from $period';
  return 'No change from $period';
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // AppColors.background
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
              );
            }

            if (state.status == DashboardStatus.failure) {
              return Center(
                child: Text(
                  state.error ?? 'Something went wrong',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              );
            }

            final summary = state.summary;
            if (summary == null) {
              return const Center(
                child: Text(
                  'No dashboard data available',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF4F46E5),
              onRefresh: () async {
                context.read<DashboardBloc>().add(LoadDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32.0 : 16.0,
                  16.0,
                  isDesktop ? 32.0 : 16.0,
                  isDesktop ? 32.0 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Header Greeting Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back, Recruitment Admin',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Here's what's happening with your recruitment funnel today.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Metrics Dynamic Flow Grid View
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = width > 1100
                            ? 4
                            : (width > 650 ? 2 : 1);

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 14,
                                mainAxisExtent:
                                    195, // Fixed card layout safety depth limit
                              ),
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return MetricCard(
                                  title: 'Open Positions',
                                  value: summary.activeJobs.toString(),
                                  icon: Icons.work_outline,
                                  themeColor: const Color(0xFF4F46E5),
                                  backgroundColor: const Color(0xFFEEF2FF),
                                  detailText: _trendText(
                                    summary.jobsTrendPct,
                                    'last week',
                                  ),
                                  sparklineData: summary.jobsSparkline,
                                  onTap: () => context.push('/manager/jobs'),
                                );
                              case 1:
                                return MetricCard(
                                  title: 'Total Applications',
                                  value: summary.totalApplications.toString(),
                                  icon: Icons.people_outline,
                                  themeColor: Colors.blue,
                                  backgroundColor: const Color(0xFFE0F2FE),
                                  detailText: _trendText(
                                    summary.applicationsTrendPct,
                                    'last week',
                                  ),
                                  sparklineData: summary.applicationsSparkline,
                                );
                              case 2:
                                return MetricCard(
                                  title: 'AI Interviews Run',
                                  value: summary.aiInterviews.toString(),
                                  icon: Icons.phone_in_talk_outlined,
                                  themeColor: Colors.orange,
                                  backgroundColor: const Color(0xFFFFF3E0),
                                  detailText:
                                      '${summary.aiInterviewsYesterday} run yesterday',
                                  sparklineData: summary.aiInterviewsSparkline,
                                );
                              case 3:
                              default:
                                return MetricCard(
                                  title: 'Average AI Match Score',
                                  value:
                                      '${summary.averageAIScore.round()}%',
                                  icon: Icons.analytics_outlined,
                                  themeColor: Colors.green,
                                  backgroundColor: const Color(0xFFE6F4EA),
                                  detailText: "Across all scored applicants",
                                );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Main Analytical Display Blocks
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: PipelineChartCard(
                              pending: summary.pendingApplications,
                              shortlisted: summary.shortlisted,
                              interviews: summary.interviewsCompleted,
                              hired: summary.hired,
                              rejected: summary.rejected,
                              onViewAll: () =>
                                  context.push('/manager/candidates'),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Top Candidates Card sits next to Pipeline Chart on Desktop
                          Expanded(
                            flex: 4,
                            child: TopCandidatesCard(
                              candidates: summary.topCandidates ?? [],
                              onViewAll: () =>
                                  context.push('/manager/candidates'),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      // Mobile / Tablet Vertical Layout Stack
                      PipelineChartCard(
                        pending: summary.pendingApplications,
                        shortlisted: summary.shortlisted,
                        interviews: summary.interviewsCompleted,
                        hired: summary.hired,
                        rejected: summary.rejected,
                        onViewAll: () => context.push('/manager/candidates'),
                      ),
                      const SizedBox(height: 24),
                      TopCandidatesCard(
                        candidates: summary.topCandidates ?? [],
                        onViewAll: () => context.push('/manager/candidates'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
