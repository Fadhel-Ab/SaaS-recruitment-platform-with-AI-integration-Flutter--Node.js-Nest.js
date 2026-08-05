import 'dart:math' as math;

import 'package:flutter/material.dart';

class PipelineChartCard extends StatelessWidget {
  final int pending;
  final int shortlisted;
  final int interviews;
  final int hired;
  final int rejected;
  final VoidCallback? onViewAll;

  const PipelineChartCard({
    super.key,
    required this.pending,
    required this.shortlisted,
    required this.interviews,
    required this.hired,
    required this.rejected,
    this.onViewAll,
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
                  onPressed: onViewAll,
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

  // Colors here must match the legend rows in _buildPipelineLegend exactly,
  // in the same order, so the donut segments correspond to their labels.
  List<MapEntry<int, Color>> _segments() => [
    MapEntry(pending, const Color(0xFF4F46E5)),
    MapEntry(shortlisted, Colors.blue),
    MapEntry(interviews, Colors.orange),
    MapEntry(hired, Colors.green),
    MapEntry(rejected, Colors.red),
  ];

  Widget _buildCircularChart(int total) {
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(140, 140),
              painter: _PipelineDonutPainter(
                segments: _segments(),
                strokeWidth: 16,
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

class _PipelineDonutPainter extends CustomPainter {
  final List<MapEntry<int, Color>> segments;
  final double strokeWidth;

  _PipelineDonutPainter({required this.segments, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = const Color(0xFFEEF2FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, backgroundPaint);

    final total = segments.fold<int>(0, (sum, entry) => sum + entry.key);
    if (total <= 0) return;

    double startAngle = -math.pi / 2; // 12 o'clock
    for (final entry in segments) {
      if (entry.key <= 0) continue;
      final sweepAngle = (entry.key / total) * 2 * math.pi;
      final segmentPaint = Paint()
        ..color = entry.value
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, segmentPaint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PipelineDonutPainter oldDelegate) {
    if (oldDelegate.strokeWidth != strokeWidth) return true;
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].key != segments[i].key ||
          oldDelegate.segments[i].value != segments[i].value) {
        return true;
      }
    }
    return false;
  }
}
