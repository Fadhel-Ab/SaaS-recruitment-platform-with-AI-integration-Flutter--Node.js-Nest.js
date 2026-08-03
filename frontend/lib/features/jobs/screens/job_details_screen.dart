import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/bloc/auth_state.dart';
import 'package:frontend/features/auth/data/models/user_role.dart';
import 'package:frontend/features/jobs/bloc/job_details_bloc.dart';
import 'package:frontend/features/jobs/bloc/job_details_state.dart';
import 'package:go_router/go_router.dart';

class JobDetailsScreen extends StatelessWidget {
  final String shareToken;

  const JobDetailsScreen({super.key, required this.shareToken});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.sizeOf(context).width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // AppColors.background
      body: SafeArea(
        child: BlocBuilder<JobDetailsBloc, JobDetailsState>(
          builder: (context, state) {
            if (state.status == JobDetailsStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
              );
            }

            if (state.status == JobDetailsStatus.failure) {
              return Center(
                child: Text(
                  state.error ?? 'Failed to load job',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              );
            }

            final job = state.job;
            if (job == null) {
              return const Center(
                child: Text(
                  'Job not found',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              );
            }

            return Column(
              children: [
                // Clean Custom Navigation Header Row
                _buildSubPageNavbar(context, job.shareToken),

                // Main Content Viewport Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32.0 : 16.0,
                      16.0,
                      isDesktop ? 32.0 : 16.0,
                      isDesktop ? 32.0 : 16.0,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: isDesktop
                            ? _buildDesktopLayout(context, job)
                            : _buildMobileLayout(context, job),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // MARK: - Navigation Bar Component
  Widget _buildSubPageNavbar(BuildContext context, String token) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => context.pop(),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
                onPressed: () {
                  final String fullUrl = '${Uri.base.origin}/jobs/$token';
                  Clipboard.setData(ClipboardData(text: fullUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job posting link copied to clipboard!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Desktop Layout View (Two-Column System)
  Widget _buildDesktopLayout(BuildContext context, dynamic job) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Primary Content Specifications
        Expanded(
          flex: 7,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJobMainIdentity(job),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(color: Color(0xFFF3F4F6), height: 1),
                  ),
                  _buildContentSection('Job Description', job.description),
                  const SizedBox(height: 32),
                  _buildContentSection('Requirements', job.requirements),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Right Column: Side Quick Information Summary Panel
        Expanded(flex: 3, child: _buildMetadataActionPanel(context, job)),
      ],
    );
  }

  // MARK: - Mobile Layout View (Stacked Linear Flow)
  Widget _buildMobileLayout(BuildContext context, dynamic job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobMainIdentity(job),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Divider(color: Color(0xFFF3F4F6), height: 1),
                ),
                _buildContentSection('Job Description', job.description),
                const SizedBox(height: 24),
                _buildContentSection('Requirements', job.requirements),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildMetadataActionPanel(context, job),
      ],
    );
  }

  // MARK: - Sub-Component Modular Builders
  Widget _buildJobMainIdentity(dynamic job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF), // AppColors.primaryLight
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            job.employmentType,
            style: const TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          job.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          job.company ?? 'Recruiting Partner',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(String title, String bodyText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          bodyText,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataActionPanel(BuildContext context, dynamic job) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Job Overview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            _buildMetadataRow(
              Icons.location_on_outlined,
              'Location',
              job.location,
            ),
            _buildMetadataRow(
              Icons.work_outline,
              'Job Type',
              job.employmentType,
            ),
            _buildMetadataRow(
              Icons.people_outline,
              'Applications Received',
              job.applications.toString(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState.status == AuthStatus.authenticated &&
                      authState.user?.role == UserRole.manager) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Managers cannot apply to jobs. Please use a candidate account.',
                        ),
                      ),
                    );
                    return;
                  }

                  context.go('/apply/${job.shareToken}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF4F46E5,
                  ), // Primary action button
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply For This Position',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
