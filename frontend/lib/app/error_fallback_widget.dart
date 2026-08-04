import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Replaces Flutter's default red/grey error box for any widget that fails
/// to build, so a broken widget reads as "something went wrong" instead of
/// a blank or cryptic box — in every build mode, not just debug.
Widget buildErrorFallback(FlutterErrorDetails details) {
  if (kDebugMode) {
    // Keep the full framework diagnostics while developing.
    return ErrorWidget(details.exception);
  }

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(16),
    color: const Color(0xFFF8F9FE),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Color(0xFF9CA3AF), size: 28),
        SizedBox(height: 8),
        Text(
          'Something went wrong.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    ),
  );
}
