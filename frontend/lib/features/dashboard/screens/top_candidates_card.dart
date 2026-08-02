import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/data/model/dashboard_summary.dart';
import 'package:frontend/features/dashboard/data/model/top_candidate.dart';

class TopCandidatesCard extends StatelessWidget {
  final List<TopCandidate>
  candidates; // Map this to your updated data payload list array

  const TopCandidatesCard({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Candidates (by AI Score)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View all',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No evaluated candidate profiles found.',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: candidates.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Color(0xFFF3F4F6), height: 1),
                itemBuilder: (context, index) {
                  final cand = candidates[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stylized Avatar with Rank Marker Circle Badge
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFEEF2FF),
                              child: Text(
                                cand.name?.substring(0, 1).toUpperCase() ?? 'C',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Center Data Blocks: Identification Metadata & Text Summaries
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cand.name ?? 'Anonymous Candidate',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                cand.role ?? 'Applied Position',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cand.summary ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Right Alignment Column: Double Score Display Framework
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildMiniScoreBadge(
                              'CV: ${cand.cvScore}%',
                              const Color(0xFFE6F4EA),
                              const Color(0xFF137333),
                            ),
                            if (cand.interviewScore != null) ...[
                              const SizedBox(height: 4),
                              _buildMiniScoreBadge(
                                'AI Call: ${cand.interviewScore}%',
                                const Color(0xFFE0F2FE),
                                Colors.blue.shade700,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniScoreBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
