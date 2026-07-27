import 'package:flutter/material.dart';

class StatusDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  const StatusDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isSuccess,
    this.primaryButtonText = 'Continue',
    this.onPrimaryPressed,
  });

  /// Presents a compact centered dialog on both web and mobile
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Inset padding ensures it leaves margins on tiny mobile screens
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          // Prevents it from stretching wide on desktop/web
          constraints: const BoxConstraints(maxWidth: 380),
          child: StatusDialog(
            title: title,
            message: message,
            isSuccess: isSuccess,
            primaryButtonText: primaryButtonText,
            onPrimaryPressed: onPrimaryPressed,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = isSuccess
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final iconData = isSuccess
        ? Icons.check_circle_rounded
        : Icons.error_rounded;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Hugs content vertically
        children: [
          // Minimal Icon Badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 32, color: statusColor),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onPrimaryPressed != null) {
                  onPrimaryPressed!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Recruitment Blue
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(primaryButtonText ?? 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
