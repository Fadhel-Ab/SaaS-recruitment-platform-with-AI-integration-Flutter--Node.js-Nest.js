import 'dart:math' as math;
import 'package:flutter/material.dart';

class AiCallWaitingOverlay extends StatefulWidget {
  final double score;
  final VoidCallback onStartCall;

  const AiCallWaitingOverlay({
    super.key,
    required this.score,
    required this.onStartCall,
  });

  @override
  State<AiCallWaitingOverlay> createState() => _AiCallWaitingOverlayState();
}

class _AiCallWaitingOverlayState extends State<AiCallWaitingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Score Indicator Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'AI Profile Matching Score: ${(widget.score * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Color(0xFF137333),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // FIX: Added explicit constraints bounding box around the stack animation loops
          SizedBox(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip
                      .none, // Allows circles to feather smoothly outwards without clipping layouts
                  children: [
                    ...List.generate(3, (index) {
                      final double progress =
                          (_animationController.value + (index / 3)) % 1.0;
                      return Container(
                        width: 80 + (progress * 100),
                        height: 80 + (progress * 100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF4F46E5,
                          ).withOpacity((1.0 - progress) * 0.25),
                        ),
                      );
                    }),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4F46E5),
                      ),
                      child: Transform.rotate(
                        angle:
                            math.sin(_animationController.value * math.pi * 2) *
                            0.15,
                        child: const Icon(
                          Icons.phone_in_talk,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 40),

          const Text(
            'Congratulations! You Qualified.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our recruitment AI module is online and ready to conduct your preliminary audio interview immediately.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // Primary Call Trigger Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onStartCall,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text(
                'Start AI Screening Call Now',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137333), // Success green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
