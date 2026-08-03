class JobSearchResult {
  final String id;
  final String title;
  final String companyName;

  const JobSearchResult({
    required this.id,
    required this.title,
    required this.companyName,
  });

  factory JobSearchResult.fromJson(Map<String, dynamic> json) {
    return JobSearchResult(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      companyName: json['companyName'] ?? '',
    );
  }
}

class CandidateSearchResult {
  final String applicationId;
  final String name;
  final String email;
  final String jobTitle;

  const CandidateSearchResult({
    required this.applicationId,
    required this.name,
    required this.email,
    required this.jobTitle,
  });

  factory CandidateSearchResult.fromJson(Map<String, dynamic> json) {
    return CandidateSearchResult(
      applicationId: json['applicationId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
    );
  }
}

class SearchResults {
  final List<JobSearchResult> jobs;
  final List<CandidateSearchResult> candidates;

  const SearchResults({required this.jobs, required this.candidates});

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      jobs: (json['jobs'] as List? ?? [])
          .map((e) => JobSearchResult.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      candidates: (json['candidates'] as List? ?? [])
          .map(
            (e) =>
                CandidateSearchResult.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }

  bool get isEmpty => jobs.isEmpty && candidates.isEmpty;
}
