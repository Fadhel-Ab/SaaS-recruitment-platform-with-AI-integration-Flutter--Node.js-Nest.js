import 'package:flutter/material.dart';

class PipelineChartCard extends StatelessWidget {
  final int pending;
  final int shortlisted;
  final int interviews;
  final int hired;
  final int rejected;

  const PipelineChartCard({
    super.key,
    required this.pending,
    required this.shortlisted,
    required this.interviews,
    required this.hired,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    final int total = pending + shortlisted + interviews + hired + rejected;
    final bool isDesktop = MediaQuery.sizeOf(context).width > 800;

    final content = isDesktop
        ? Row(
            children: [
              Expanded(flex: 4, child: _buildCircularChart(total)),
              const SizedBox(width: 32),
              Expanded(flex: 6, child: _buildPipelineLegend(total)),
            ],
          )
        : Column(
            children: [
              _buildCircularChart(total),
              const SizedBox(height: 24),
              _buildPipelineLegend(total),
            ],
          );

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
                  'Candidate Pipeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View full pipeline',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildCircularChart(int total) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: total > 0
                  ? 0.75
                  : 0.0, // Base visual mock indicator mapping design chart
              strokeWidth: 16,
              color: const Color(0xFF4F46E5),
              backgroundColor: const Color(0xFFEEF2FF),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const Text(
                'Total',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineLegend(int total) {
    return Column(
      children: [
        _buildLegendRow(
          'Pending Screening',
          pending,
          total,
          const Color(0xFF4F46E5),
        ),
        _buildLegendRow(
          'Shortlisted Candidates',
          shortlisted,
          total,
          Colors.blue,
        ),
        _buildLegendRow('Interviews Booked', interviews, total, Colors.orange),
        _buildLegendRow('Offers Extended / Hired', hired, total, Colors.green),
        _buildLegendRow('Archived / Rejected', rejected, total, Colors.red),
      ],
    );
  }

  Widget _buildLegendRow(String title, int count, int total, Color color) {
    final double percentage = total > 0 ? (count / total) * 100 : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 45,
            child: Text(
              '(${percentage.toStringAsFixed(0)}%)',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}
