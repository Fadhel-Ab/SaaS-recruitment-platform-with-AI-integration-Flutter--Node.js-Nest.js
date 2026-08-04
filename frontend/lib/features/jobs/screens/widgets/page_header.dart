import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final bool isDesktop;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.isDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final headerTextGroup = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 20 : 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827), // Dashboard charcoal black
            letterSpacing: -0.5,
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280), // Dashboard subtitle grey
            ),
          ),
        ],
      ],
    );

    final actionButton = ElevatedButton.icon(
      onPressed: onButtonPressed,
      icon: Icon(Icons.add, size: isDesktop ? 18 : 16, color: Colors.white),
      label: Text(
        buttonLabel,
        style: TextStyle(
          fontSize: isDesktop ? 14 : 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5), // Dashboard primary blue
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 18 : 14,
          vertical: isDesktop ? 12 : 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Responsive structural delivery
    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: headerTextGroup),
            const SizedBox(width: 16),
            actionButton,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: headerTextGroup),
          const SizedBox(width: 10),
          actionButton,
        ],
      ),
    );
  }
}
