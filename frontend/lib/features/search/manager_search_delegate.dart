import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/features/search/data/search_repository.dart';
import 'package:frontend/features/search/model/search_results.dart';

class ManagerSearchDelegate extends SearchDelegate<void> {
  final SearchRepository repository;

  ManagerSearchDelegate(this.repository)
    : super(searchFieldLabel: 'Search jobs and candidates...');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    final trimmed = query.trim();

    if (trimmed.length < 2) {
      return const Center(
        child: Text(
          'Keep typing to search your jobs and candidates',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
      );
    }

    return FutureBuilder<SearchResults>(
      future: repository.search(trimmed),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Search failed: ${snapshot.error}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          );
        }

        final results = snapshot.data;
        if (results == null || results.isEmpty) {
          return const Center(
            child: Text(
              'No results found',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          );
        }

        return ListView(
          children: [
            if (results.jobs.isNotEmpty) ...[
              const _SectionHeader('Jobs'),
              ...results.jobs.map(
                (job) => ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEEF2FF),
                    child: Icon(Icons.work_outline, color: Color(0xFF4F46E5)),
                  ),
                  title: Text(job.title),
                  subtitle: Text(job.companyName),
                  onTap: () {
                    close(context, null);
                    context.push('/manager/jobs/${job.id}/applicants');
                  },
                ),
              ),
            ],
            if (results.candidates.isNotEmpty) ...[
              const _SectionHeader('Candidates'),
              ...results.candidates.map(
                (candidate) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: Text(
                      candidate.name.isNotEmpty
                          ? candidate.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(candidate.name),
                  subtitle: Text('${candidate.email} · ${candidate.jobTitle}'),
                  onTap: () {
                    close(context, null);
                    context.push(
                      '/manager/applications/${candidate.applicationId}',
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
