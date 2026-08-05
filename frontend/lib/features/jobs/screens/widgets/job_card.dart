import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard actions

class JobCard extends StatelessWidget {
  final dynamic job;
  final VoidCallback onTap;
  final bool isDesktop;
  final int index;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.index,
    this.isDesktop = true,
  });

  // HELPER: Calculates human-readable relative time strings natively
  String _getRelativeTimeString(dynamic createdAtValue) {
    if (createdAtValue == null) return 'Just now';

    DateTime dateTime;
    if (createdAtValue is DateTime) {
      dateTime = createdAtValue;
    } else if (createdAtValue is String) {
      dateTime = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      return 'Just now';
    }

    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      // Fallback display format if it crosses beyond a full month time tracking cycle
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    }
  }

  // METHOD: Copies target token share routing link directly to user clipboard overlay
  void _copyShareLink(BuildContext context) {
    final String baseUrl = Uri.base.origin;
    final String shareUrl = '$baseUrl/#/jobs/${job.shareToken ?? ''}';

    Clipboard.setData(ClipboardData(text: shareUrl)).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied link: $shareUrl'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            width: 300,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 12.0),
          child: isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconBox(),
        const SizedBox(width: 20),

        // Main Meta Column (Title, Company, Location, and Time)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title ?? 'Senior Software Engineer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    job.company ?? 'TalentHQ Corp',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.location ?? 'San Francisco, CA',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  // Relative timestamp injected here
                  Text(
                    _getRelativeTimeString(job.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInlineMetric('Applications', '${job.applications ?? 0}'),
            ],
          ),
        ),

        if (job.isUrgent == true) ...[
          _buildUrgentBadge(),
          const SizedBox(width: 12),
        ],
        _buildStatusPill(job.status ?? 'Active'),
        const SizedBox(width: 12),

        // Share Action Copy Button Wrapper
        IconButton(
          tooltip: 'Copy Share Link',
          icon: const Icon(
            Icons.share_outlined,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          onPressed: () => _copyShareLink(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconBox(size: 36, iconSize: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      job.title ?? 'Senior Software Engineer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (job.isUrgent == true) ...[
                    _buildUrgentBadge(compact: true),
                    const SizedBox(width: 6),
                  ],
                  _buildStatusPill(job.status ?? 'Active', compact: true),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '${job.company ?? 'TalentHQ'} • ${job.location ?? 'Remote'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              Text(
                '${job.applications ?? 0} applicants • ${_getRelativeTimeString(job.createdAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: Color(0xFF6B7280),
            size: 16,
          ),
          onPressed: () => _copyShareLink(context),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.only(left: 6),
        ),
      ],
    );
  }

  Widget _buildIconBox({double size = 48, double iconSize = 22}) {
    if (job.isUrgent == true) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            Icons.local_fire_department,
            color: const Color(0xFFEA580C),
            size: iconSize,
          ),
        ),
      );
    }

    final List<Color> colors = [
      const Color(0xFF4F46E5),
      Colors.blue,
      Colors.pink,
      Colors.green,
    ];
    final List<Color> bgs = [
      const Color(0xFFEEF2FF),
      const Color(0xFFE0F2FE),
      const Color(0xFFFCE7F3),
      const Color(0xFFE6F4EA),
    ];
    final int colorIndex = index % colors.length;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgs[colorIndex],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          Icons.business_center_outlined,
          color: colors[colorIndex],
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildUrgentBadge({bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFED7AA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: compact ? 11 : 14,
            color: const Color(0xFF9A3412),
          ),
          const SizedBox(width: 4),
          Text(
            'URGENT',
            style: TextStyle(
              color: const Color(0xFF9A3412),
              fontWeight: FontWeight.w800,
              fontSize: compact ? 9 : 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineMetric(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status, {bool compact = false}) {
    final bool isPhase =
        status.toLowerCase().contains('phase') ||
        status.toLowerCase().contains('offer');
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: isPhase ? const Color(0xFFFFF3E0) : const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPhase ? const Color(0xFFE65100) : const Color(0xFF137333),
          fontWeight: FontWeight.w600,
          fontSize: compact ? 10 : 12,
        ),
      ),
    );
  }
}
